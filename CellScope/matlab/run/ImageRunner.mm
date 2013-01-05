//
//  ImageRunner.m
//  CellScope
//
//  Runs the algorithm on an image, or multiple images selected by the user
//
//  Created by Wayne Gerard on 12/8/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//
//

#import "ImageRunner.h"
#import "ImageTools.h"
#import "Globals.h"
#import <opencv2/core/core_c.h>

@implementation ImageRunner

/**
    @param hogFeatures Whether to include or exclude HoG features
    @return Returns a CSV file with centroids and scores
 */
- (void) runWithHoG: (BOOL) hogFeatures viewPatches:(BOOL) viewPatches patchSize:(int) patchSize
{
    // CELLSCOPE methods:
    // blobid
    // regionprops
    // compute_gradient
    // mybinarize
    // calcfeats
    // train_max
    // train_min
    
    // MATLAB methods:
    // repmat
    // bwconncomp - possible replacement cvFindContours
    
    // GENERAL methods:
    // 1. Some kind of matrix cloning method
    
    // Handle incorrect parameters
    patchSize  = (patchSize %% 2 != 0) ? 24 : patchSize;
    
    // TODO: Return CSV instead of void
    /*% OUTPUT: CSV file(s) with centroids and scores
    % - ctrs_sort: array of centroids, sorted by descending patch score. Each
    %   row contains (row,col) indices.
    % - scrs_sort: corresponding scores (likelihood of being bacilli)
    */
    if (hogFeatures) {
        // TODO: Load the model without HoG features
    } else {
        // TODO: Load model with HoG features
    }
    
    // TODO: Let user choose images
    NSMutableArray* images = [NSMutableArray arrayWithCapacity:1];
    int count = [images count];

    
    // Start timing
    // TODO: Timing
    for (int i =0; i < count; i++) {
        CSLog(@"Processing image %d of %d", i, count);
        UIImage* ui_img = [images objectAtIndex:i];
        
        // Convert the image to an OpenCV matrix
        Mat image = [ImageTools cvMatWithImage:ui_img];
        if(!image.data) // Check for basic errors
        {
            CSLog(@"Could not load image with filename");
            return;
        }

        orig = im2double(orig(:,:,1));
        
        //Perform object identification
        imbw = blobid(orig,0); % Use Gaussian kernel method
        
        imbwCC = bwconncomp(imbw);
        imbwCC.stats = regionprops(imbwCC,orig,'WeightedCentroid');
    
        // Computer gradient image for HoG features
        if (hogfeatures) {
            gradim = compute_gradient(orig,8);
        }
        
        // Exclude partial patches, do non-max suppression, store centroid/patch content
        int q = 0;
        
        // update vector of centroid values
        centroids = round(vertcat(imbwCC.stats(:).WeightedCentroid)); % col idx in col 1, row idx in col 2

        for (int s = 0; s < imbwCC.numObjects; s++) {
            int partial = -1;
            int col = centroids[s][0];
            int row = centroids[s][2];
            
            // Check that patch is complete (not partial)
            bool complete_1 = col - patchSize / 2 > 0 && row - patchSize /  > 0;
            bool complete_2 = col + (sz / 2 -1) <= size(orig, 2);
            bool complete_3 = row + (sz/2 - 1) <= size(orig,1));
            if (complete_1 && complete_2 && complete_3) { // ensure the patch is complete (doesn't run off edge of image)
                partial = 0;
            } else { // partial patch, so discard
                partial = 1;
            }
            
            // Store good centroiss
            if (partial == 0) {
                q++;
                data.stats[q].col = col;
                data.stats[q].row = row;
                // Indices in matlab are 1 based
                int index_1 = (row - patchSize / 2) - 1;
                int index_2 = row + (patchSize/2 - 1) - 1;
                int index_3 = col - patchSize/2 - 1;
                int index_4 = col + (patchSize / 2 - 1) - 1;
                data.stats[q].patch = orig(index_1:index_2, index_3:index_4); // Store patch for viewing later
                [data.stats(q).binpatch, prethresh, nullobj] = mybinarize(data.stats(q).patch);
                
                if (hogFeatures) {
                    gradpatch = gradim(row-sz/2:row+(sz/2-1),col-sz/2:col+(sz/2-1),:);
                    data.stats(q).gradpatch = gradpatch;
                }
            
            }
        }
        data.numObjects = q;
        
        // Calculate features
        data = calcfeats(data, patchSize, hogFeatures);
        
        
        NSMutableArray* patches = [NSMutableArray array];
        NSMutableArray* binPatches = [NSMutableArray array];
        float[][] ctrs;
        for (int j = 0; j < data.numObjects; j++) {
            
            // ctrs will be a [data.numObjects, 2] matrix
            // containing the stats row and col
            
            // feats will be a [data.numObjects, 2/3] matrix
            // containing the phi, geom, and possibly the hog
            
            
            ctrs(t,:) = [data.stats(t).row data.stats(t).col];
            
            if dohog
                feats(t,:) = [data.stats(t).phi data.stats(t).geom data.stats(t).hog];
            else
                feats(t,:) = [data.stats(t).phi data.stats(t).geom];
            end
            binpatches{1,t} = data.stats(t).binpatch;
            patches{1,t} = data.stats(t).patch;
        }
        
        // Prepare features and run object-level classifier
        Xtest = feats;
        ytest_dummy = zeros(size(Xtest,1),1);
        
        // Minmax normalization of features
        maxmat = repmat(train_max,size(ytest_dummy));
        minmat = repmat(train_min,size(ytest_dummy));
        Xtest = (Xtest-minmat)./(maxmat-minmat);
        
        //////////////////////
        // Classify Objects //
        //////////////////////
        
        // LibSVM IKSVM classifier
        [pltest, accutest, dvtest] = svmpredict(double(ytest_dummy),double(Xtest),model,'-b 1');
        dvtest = dvtest(:,model.Label==1);
        
        // NOTE: We don't need to do logistic regression because it's built into LibSVM

        // Sort scores and centroids
        [scrs_sort, Isort] = sort(dvtest,'descend');
        ctrs_sort = ctrs(Isort,:);
        
        
        
        //Drop extremely low-confidence patches
        lowlim = 1e-6;
        Ikeep = scrs_sort>lowlim;
        scrs_sort = scrs_sort(Ikeep);
        ctrs_sort = ctrs_sort(Ikeep,:);
        
        
        // Non-max suppression based on scores
        maxdist = sqrt(size(orig,1)^2 + size(orig,2)^2);
        cp_ctrs_sort = ctrs_sort;
        Isupp = zeros(length(scrs_sort),1);
        for u = 1:length(scrs_sort) % starting from highest-scoring patch
            row = cp_ctrs_sort(u,1); col = cp_ctrs_sort(u,2);
            dist = sqrt((row-cp_ctrs_sort(:,1)).^2 + (col-cp_ctrs_sort(:,2)).^2);
         
            dist(dist==0) = maxdist; % for current patch, artificially elevate so that won't be counted as min
            [mindist,idx] = min(dist); % find closest patch to see if too much overlap
         
            tooclose = 0.75*sz; % non-max suppression parameter, "too close" distance
            if(mindist <= tooclose) % if too much overlap
                cp_ctrs_sort(idx,1) = -size(orig,1); cp_ctrs_sort(idx,2) = -size(orig,2); % prevent triggering non-max again/get rid of lower-score object
                Isupp(u) = 1; % suppress this patch
            end
         end
         
         scrs_sort = scrs_sort(~Isupp);
         ctrs_sort = ctrs_sort(~Isupp,:);
         
        // TODO: Stop timing
        csvwrite(['./out_',fname(1:end-4),'.csv'],[ctrs_sort scrs_sort]);
    }
    
    
}

@end
