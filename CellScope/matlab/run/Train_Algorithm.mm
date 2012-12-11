//
//  Train_Algorithm.m
//  CellScope
//
//  Created by Wayne Gerard on 12/10/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "Train_Algorithm.h"

@implementation Train_Algorithm

- (void) trainAlgorithm {
    
    /*
    function trainalg_mike(varargin)
    % TRAINALG_MIKE trains a new object-level classifier, optimizing over
    % slide-level performance.
    % USAGE: trainalg_mike(imdir,sel,param,dohog)
    % Inputs:   -imdir = main image directory. **Important: See required
    %               "train_readme" file for required directory structure.
        %           -sel = specifies optimization method.  All these metrics
        %               refer to slide-level performance. Default = 3.
        %               (1) maximize F_beta-measure over sensitivity/specificity
        %                   curve.
        %               (2) maximize specificity at a preset sensitivity value
        %               (3) maximize sensitivity at a preset specificity value
        %           -param = parameter for optimization method specified by sel. Default = 0.96.
            %               sel = 1: param corresponds to beta
            %               sel = 2: param corresponds to preset sensitivity value
            %               sel = 3: param corresponds to preset specificity value
            %           -dohog = 1 to include HoG features (0 to exclude)
            % Output: Creates model_out_whog.mat or model_out_wohog.mat, which contains
            %         the LibSVM model structure and parameter settings.
            % Author: Jeannette Chang, 4/26/12
            
            % Get user inputs or use default values
            if length(varargin)<4
                fprintf('Warning: Not enough inputs, so used default input values:\n')
                imdir = '.\imgs\'; %'C:\Users\jnchang\Documents\Fletcher Lab\CellScope Images\uganda_Jan12\'
                sel = 3
                param = 0.96
                dohog = 1
                else
                    imdir = varargin{1};
    sel = varargin{2};
    param = varargin{3};
    dohog = varargin{4};
    end
    
    % Add paths
    addpath('.\objlevel')
    addpath('.\other')
    addpath('.\train')
    overalltic = tic;
    
    %% System parameters
    opt = 5; % LibSVM option: 0 = Linear, 3 = GRBF, 5 = IKSVM.
    liblin = 0; % (1/0) if using liblinear/libsvm.  If using liblinear, will create logitreg.mat model file if using a SVM option
        dologitreg = (liblin && opt ~= 6 && opt ~= 7); % Libsvm already outputs probilities, so no need for logitreg
            sz = 24; % size of candidate object patch (may need to change in other places)
    save sysparams.mat opt liblin dohog dologitreg
    
    %% Save objects and features in images
    setup_train_mike(imdir,sz);
    % runall   % save objects and features - instruct to run once for a given dataset.
        prepdata_mike;  % saves train.mat and test.mat
    load train.mat
    
    % select subset of features
    if dohog % 22 orig + HoG
        Xtrainnorm = Xtrainnorm(:,1:102);
    train_max = train_max(1,1:102);
    train_min = train_min(1,1:102);
    else % Hu/Photo/Geom (22 orig)
        Xtrainnorm = Xtrainnorm(:,1:22);
    train_max = train_max(1,1:22);
    train_min = train_min(1,1:22);
    end
    
    % Potential cost parameters for object-level classifier
        cexps = -5:2:9; % cost = 2^(cexp), -3 turned out to be best parameter for Uganda data
            
            %% Find cost parameter that gives best slide-level test set performance
            for n = 1:length(cexps)
                cost = 2^cexps(n);
    
    if liblin
        tlbx = 'LIBLINEAR';
    else
        tlbx = 'LIBSVM';
    end
    fprintf('Using %s toolbox to train SVM with cost %d and kernel %d\n',tlbx,cost,opt)
    
    %% Train Object-Level Classifier %%
    if liblin % LibLinear
        model = train(double(ytrain),sparse(double(Xtrainnorm)),['-s ',num2str(opt),' -c ',num2str(cost),' -q']);
    [pltrain, accutrain, dvtrain] = predict(double(ytrain),sparse(double(Xtrainnorm)),model,'-b 1');
    else % LibSVM
        model = svmtrain(double(ytrain),double(Xtrainnorm),['-t ',num2str(opt),' -b 1 -c ',num2str(cost)]);
    [pltrain, accutrain, dvtrain] = svmpredict(double(ytrain),double(Xtrainnorm),model,'-b 1');
    end
    
    dvtrain = dvtrain(:,model.Label==1);
    
    if dologitreg
        dummy = logitreg(dvtrain,ytrain,1); % train a logistic regression on top of SVM
    end
    
    save('model_out.mat','model','opt','train_max','train_min','cost','dologitreg')
    
    %% Object-Level Training Set Performance %%
    if dologitreg
        dvtrain = logitreg(dvtrain,ytrain,2);
    end
    save('train_out.mat','dvtrain','ytrain')
    
    % Determine number of missed objects in train and test sets after
    % candidate object identification step
    [missed_train, missed_test] = getnummissed_mike;
    
    [confid,I] = sort(dvtrain,'descend');
    y_sort = ytrain(I);
    sens = cumsum(y_sort)/(sum(y_sort)+missed_train);
    y_revsort = flipud(y_sort);
    spec = flipud(cumsum([0; ~y_revsort(1:end-1)]))/sum(y_sort==0); % see 9/17/11 notes for explanation
        tmp = 1:length(y_sort);
    prec = cumsum(y_sort)./tmp';
    
    obj_avgspec_train = trapz(sens, spec);
    obj_avgprec_train = trapz(sens, prec);
    sens_train = sens; spec_train = spec; prec_train = prec;
    fprintf('Object-Level Training Set Performance:\n  Avg precision: %1.4f\n  Avg Specificity: %1.4f\n',obj_avgprec_train,obj_avgspec_train);
    
    %% Object-Level Test Set Performance %%
    load test.mat
    % select subset of features
    if dohog
        Xtest = Xtest(:,1:102);
    else
        Xtest = Xtest(:,1:22);
    end
    
    % minmax normalization
    maxmat = repmat(train_max,size(ytest));
    minmat = repmat(train_min,size(ytest));
    Xtest_in = (Xtest-minmat)./(maxmat-minmat);
    
    if liblin
        % LibLinear
        [pltest, accutest, dvtest] = predict(double(ytest),sparse(double(Xtest_in)),model,'-b 1');
    else
        % LibSVM
        [pltest, accutest, dvtest] = svmpredict(double(ytest),double(Xtest_in),model,'-b 1');
    end
    dvtest = dvtest(:,model.Label==1);
    
    if dologitreg
        dvtest = logitreg(dvtest,ytest,2);
    end
    
    [confid,I] = sort(dvtest,'descend');
    y_sort = ytest(I);
    
    sens = cumsum(y_sort)/(sum(y_sort)+missed_test);
    y_revsort = flipud(y_sort);
    spec = flipud(cumsum([0; ~y_revsort(1:end-1)]))/sum(y_sort==0); % see 9/17/11 notes for explanation
        tmp = 1:length(y_sort);
    prec = cumsum(y_sort)./tmp';
    
    obj_avgspec_test = trapz(sens, spec);
    obj_avgprec_test = trapz(sens, prec);
    sens_test = sens; spec_test = spec; prec_test = prec;
    
    save('test_out.mat','dvtest','ytest')
    fprintf('Object-Level Test Set Performance:\n  Avg Precision: %1.4f\n  Avg Specificity: %1.4f\n',obj_avgprec_test,obj_avgspec_test);
    
    %     %%% Plot object-level performance
    %     figure; hold on; grid on;
    %     plot(sens_train, spec_train,'b--','LineWidth',2);
    %     plot(sens_train, prec_train,'b-','LineWidth',2);
    %     plot(sens_test, spec_test,'r--','LineWidth',2);
    %     plot(sens_test, prec_test,'r-','LineWidth',2);
    %     hold off;
    %     legend('train-SS','train-RP','test-SS','test-RP','Location','SouthWest');
    %     title(['Object-Level SS/RP curves, Avg Prec: ',num2str(obj_avgprec_test),', Avg Spec: ',num2str(obj_avgspec_test),' Cost: ',num2str(cost),]);
    %     xlabel('Recall (Sensitivity)'); ylabel('Precision (Specificity)');
    
    %% Slide-Level Test Set Classification %%
    disp('Start calculating SVM scores for slide-level test...')
    disp('Getting scores based on trained SVM...')
    getscores_slidelevel_new_mike
    
    disp('Combining scores that originated form the same slide...')
    combinescores_mike
    
    disp('Classifying slides using avgtop method...')
    [allslideperf(1,n),allslidesens(n,:),allslideprec(n,:),allslidespec(n,:)] = classifyslides_mike(sel,param);
    
    end
    save results_tmp sel param allslidesens allslideprec allslidespec allslideperf
    % save objresults obj_avgprec_test obj_avgprec_train obj_avgspec_test obj_avgspec_train
    
    [bestperf,bestidx] = max(allslideperf);
    switch sel
case 1 % maximize F_beta measure
    fprintf('Best F_beta measure achieved was %2.1f (beta = %1.1f). Saving model with cost = 2^%d...\n',bestperf*100,param,cexps(bestidx));
case 2 % maximize specificity for a preset sensitivity
    fprintf('Given sensitivity of %2.1f, best specificity achieved was %2.1f. Saving model with cost = 2^%d...\n',param*100,bestperf*100,cexps(bestidx));
case 3 % maximize sensitivity for a preset specificity
    fprintf('Given specificity of %2.1f, best sensitivity achieved was %2.1f. Saving model with cost = 2^%d...\n',param*100,bestperf*100,cexps(bestidx));
    end
    
    %%% Save optimized model file(s) %%%
    % I.e., save model with cost parameter that gave best performance
    % slide-level test set performance
    cost = 2^cexps(bestidx);
    
    if liblin % LibLinear
        model = train(double(ytrain),sparse(double(Xtrainnorm)),['-s ',num2str(opt),' -c ',num2str(cost),' -q']);
    else % LibSVM
        model = svmtrain(double(ytrain),double(Xtrainnorm),['-t ',num2str(opt),' -b 1 -c ',num2str(cost)]); 
    end
    
    if dohog
        save('model_out_whog.mat','model','opt','train_max','train_min','cost','dologitreg')
        else
            save('model_out_wohog.mat','model','opt','train_max','train_min','cost','dologitreg')
            end
            
            if dologitreg
                dummy = logitreg(dvtrain,ytrain,1); % train a logistic regression on top of SVM (save in logit_model.mat)
    end
    
    save best bestperf bestidx
    disp('Overall time elapsed is...'); toc(overalltic)
    
    */
}

@end
