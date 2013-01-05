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
// im2double
// bwconncomp - possible replacement cvFindContours

// GENERAL methods:
// 1. Some kind of matrix cloning method


- (void) mainWithHogFeatures: (BOOL) hog wthPatchSize: (int) patchSz {

    // Handle incorrect parameters
    patchSize  = (patchSize % 2 != 0) ? 24 : patchSz;
    hogFeatures = hog;

    if (hogFeatures) {
        // TODO: Load the model without HoG features
    } else {
        // TODO: Load model with HoG features
    }
    
    // Start timing
    // TODO: Timing

    // TODO: Let user choose images
    NSMutableArray* images = [NSMutableArray arrayWithCapacity:1];
    int count = [images count];
    
    for (int i = 0; i < count; i++) {
        CSLog(@"Processing image %d of %d", i, count);
        UIImage* ui_img = [images objectAtIndex:i];
        [self runWithImage:ui_img];
    }
    
    // TODO: Stop timing
}

/**
    Converts an image (as a Mat) to a red-channel only normalized image, with pixel intensities between 0..1
    @param image The image, assumed to be a color image with all 3 channels
    @return Returns an the red-channel normalized image
 */
- (Mat) getRedImageNormalizedImage: (Mat) image {
    // ASK: Is this right?
    // Use only red channel for image
    
    // WN: I have no idea if this is the right thing to be doing
    // This seems to suggest so: http://www.cs.bc.edu/~hjiang/c335/notes/lec3/lec3.pdf
    Mat red(image.rows, image.cols, CV_8UC1);
    Mat green(image.rows, image.cols, CV_8UC1);
    Mat blue(image.rows, image.cols, CV_8UC1);
    cvSplit(&image, &red, &green, &blue, 0);
    
    // ASK: Normalize to values between [0, 1] ?
    // Normalize the image to values between 0..1
    orig = Mat(image.rows, image.cols, CV_32F);
    Mat red_32F(image.rows, image.cols, CV_32F);
    convertScaleAbs(red, red_32F);
    cvNormalize(&orig, &red_32F);
    normalize(red_32F, orig, 0, NORM_MINMAX);
}

/**
    Checks patches for completness, and if patches are complete then returns a dictionary containing the following
    information:
    
    1) The column 
    2) The row
    3) The patch
    4) Possibly the gradient patch, if HoG features are enabled
 */
- (void) storeGoodCentroidsWithRow:(int) row withCol:(int) col {
    
    /////////////////////////////////
    // Patch Completeness Checking //
    /////////////////////////////////
    bool partial = NO;
    
    // Lower bounds checking
    int lowerC = col - patchSize / 2;
    int lowerR = row - patchSize / 2;
    if (lowerC <= 0 || lowerR <= 0) {
        partial = YES;
    }
    
    // Higher bounds checking
    int higherC = (col + (patchSize / 2 - 1));
    int higherR = (row + (patchSize / 2 - 1));
    
    if ((higherC > orig.cols) || (higherR  > orig.rows)) {
        partial = YES;
    }
    
    //////////////////////////
    // Store good centroids //
    //////////////////////////
    
    if (partial) {
        return;
    }
    
    patchCount++;
    
    data.stats[patchCount].col = col;
    data.stats[patchCount].row = row;
    
    // Indices in matlab are 1 based
    int row_start = (row - patchSize / 2) - 1; // IM
    int row_end = row + (patchSize / 2 - 1) - 1; // IM
    int col_start = col - patchSize / 2 - 1; // IM
    int col_end = col + (patchSize / 2 - 1) - 1; // IM
    data.stats[patchCount].patch = orig(row_start:row_end, col_start:col_end); // Store patch for viewing later
    [data.stats(patchCount).binpatch, prethresh, nullobj] = mybinarize(data.stats(q).patch);
    
    if (hogFeatures) { // IM
        gradpatch = gradim(row-patchSize/2:row+(patchSize/2-1),col-patchSize/2:col+(patchSize/2-1),:);
        data.stats(patchCount).gradpatch = gradpatch;
    }

}

/**
    @param img The Image to run on
    @return Returns a CSV file with centroids and scores
 */
- (void) runWithImage: (UIImage*) img
{
    
    // TODO: Return CSV instead of void
    /*% OUTPUT: CSV file(s) with centroids and scores
    % - ctrs_sort: array of centroids, sorted by descending patch score. Each
    %   row contains (row,col) indices.
    % - scrs_sort: corresponding scores (likelihood of being bacilli)
    */


    // Convert the image to an OpenCV matrix
    Mat image = [ImageTools cvMatWithImage:img];
    if(!image.data) // IM
    {
        CSLog(@"Could not load image with filename"); 
        return;
    }
    
    orig = [self getRedImageNormalizedImage:image];
    
    // Perform object identification
    // TODO imbw = blobid(orig,0); % Use Gaussian kernel method
    
    // TODO imbwCC = bwconncomp(imbw);
    // TODO imbwCC.stats = regionprops(imbwCC,orig,'WeightedCentroid');

    // Computer gradient image for HoG features
    if (hogFeatures) { // IM
        // TODO gradim = compute_gradient(orig,8);
    }
    
    // Exclude partial patches, do non-max suppression, store centroid/patch content
    int patchCount = 0; // IM
    
    // update vector of centroid values
    // TODO centroids = round(vertcat(imbwCC.stats(:).WeightedCentroid)); // col idx in col 1, row idx in col 2

    // TODO int numObjects = imbwCC.numObjects;
    for (int j = 0; j < numObjects; j++) { // IM
        int col = centroids[j][0];
        int row = centroids[j][2];
        
        
    }
    data.numObjects = patchCount;
    
    // Calculate features
    data = calcfeats(data, patchSize, hogFeatures);
    
    
    NSMutableArray* patches = [NSMutableArray array];
    NSMutableArray* binPatches = [NSMutableArray array];
    Mat* ctrs;
    Mat* feats;

    ctrs = Mat(patchCount, 2, CV_8UC1);
    if (hogFeatures) {
        feats = Mat(patchCount, 3, CV_8UC1);
    } else {
        feats = Mat(patchCount, 2, CV_8UC1);
    } 
    
    for (int j = 0; j < patchCount; j++) {
        
        ctrs(t,:) = [data.stats(t).row data.stats(t).col];
        
        if (hogFeatures) { 
            feats(t,:) = [data.stats(t).phi data.stats(t).geom data.stats(t).hog];
        } else { // IM
            feats(t,:) = [data.stats(t).phi data.stats(t).geom];
        }
        binpatches{1,t} = data.stats(t).binpatch;
        patches{1,t} = data.stats(t).patch;
    }
    
    // Prepare features and run object-level classifier
    Xtest = feats;
    ytest_dummy = zeros(size(Xtest,1),1); // WN: Pretty sure this is equivalent to patchCount, 1
    
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
    
    /////////////////////////////////
    // Drop Low-confidence Patches //
    /////////////////////////////////
    float lowlim = 1e-6; // IM
    
    Ikeep = scrs_sort>lowlim;
    scrs_sort = scrs_sort(Ikeep);
    ctrs_sort = ctrs_sort(Ikeep,:);
    
    /////////////////////////////////////////
    // Non-max Suppression Based on Scores //
    /////////////////////////////////////////
    
    maxdist = sqrt(size(orig,1)^2 + size(orig,2)^2);
    cp_ctrs_sort = ctrs_sort;
    Isupp = zeros(length(scrs_sort),1);
    for u = 1:length(scrs_sort) // starting from highest-scoring patch
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
     
    csvwrite(['./out_',fname(1:end-4),'.csv'],[ctrs_sort scrs_sort]);
}

    
}

@end
