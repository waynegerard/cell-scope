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
#import "MatrixOperations.h"
#import <opencv2/core/core_c.h>

@implementation ImageRunner

@synthesize patchSize = _patchSize, orig = _orig, hogFeatures = _hogFeatures;

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
    Mat orig = Mat(image.rows, image.cols, CV_32F);
    Mat red_32F(image.rows, image.cols, CV_32F);
    convertScaleAbs(red, red_32F);
    cvNormalize(&orig, &red_32F);
    normalize(red_32F, orig, 0, NORM_MINMAX);
    return orig;
}

/**
    Checks patches for completness, and if patches are complete then returns a dictionary containing the following
    information:
    
    1) The column [col: NSNumber]
    2) The row [row: NSNumber]
    3) The patch [patch: Mat]
    4) The binary patch
    5) Possibly the gradient patch, if HoG features are enabled [gradPatch: Mat]
 
    @param row The row for this centroid
    @param col The column for this centroid
    @return    Returns a NSMutableDictionary containing the above 4 values with the key-value pairs in parantheses.
               Will return NULL if this is a partial patch
 */
- (NSMutableDictionary*) storeGoodCentroidsWithRow:(int) row withCol:(int) col {
    
    NSMutableDictionary* stats = [NSMutableDictionary dictionary];
    
    /////////////////////////////////
    // Patch Completeness Checking //
    /////////////////////////////////
    bool partial = NO;
    
    // Lower bounds checking
    int lowerC = col - self.patchSize / 2;
    int lowerR = row - self.patchSize / 2;
    if (lowerC <= 0 || lowerR <= 0) {
        partial = YES;
    }
    
    // Higher bounds checking
    int higherC = (col + (self.patchSize / 2 - 1));
    int higherR = (row + (self.patchSize / 2 - 1));
    
    if ((higherC > self.orig.cols) || (higherR  > self.orig.rows)) {
        partial = YES;
    }

    if (partial) {
        return NULL;
    }

    //////////////////////////
    // Store good centroids //
    //////////////////////////
    
    [stats setValue:[NSNumber numberWithInt:col] forKey:@"col"];
    [stats setValue:[NSNumber numberWithInt:row] forKey:@"row"];
    
    // Indices in matlab are 1 based
    int row_start = (row - self.patchSize / 2) - 1;
    int row_end = row + (self.patchSize / 2 - 1) - 1;
    int col_start = col - self.patchSize / 2 - 1;
    int col_end = col + (self.patchSize / 2 - 1) - 1;
    Range rows = Range(row_start, row_end);
    Range cols = Range(col_start, col_end);
    
    Mat _patch = self.orig.operator()(rows, cols);
    id patch = [MatrixOperations convertMatToObject:_patch];
    [stats setValue:patch forKey: @"patch"];

    /* WAYNE NOTE: This isn't being used anywhere - do we need this method?
    if (self.hogFeatures) {
        int patchCenter = self.patchSize / 2;
        int row_start = row - patchCenter - 1;
        int row_end = row + patchCenter - 1;
        int col_start = col - patchCenter - 1;
        int col_end = col + patchCenter - 1;
        
        Range rows = Range(row_start, row_end);
        Range cols = Range(col_start, col_end);
        Mat _gradpatch = gradim(rows, cols);
        id gradpatch = [MatrixOperations convertMatToObject:_gradpatch];
        [stats setValue:gradpatch forKey: @"gradpatch"];
    }
     */
    
    return stats;
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
    
    self.orig = [self getRedImageNormalizedImage:image];
    NSMutableArray* data = [NSMutableArray array];
    
    // Perform object identification
    // TODO imbw = blobid(orig,0); % Use Gaussian kernel method
    
    // TODO imbwCC = bwconncomp(imbw);
    // TODO imbwCC.stats = regionprops(imbwCC,orig,'WeightedCentroid');

    // Computer gradient image for HoG features
    if (self.hogFeatures) { // IM
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
        
        NSMutableDictionary* stats  = [self storeGoodCentroidsWithRow:row withCol:col];
        if (stats != NULL) { // If not a partial patch
            patchCount++;
            [data addObject:stats];
            
        }
    }
    
    // Calculate features
    data = calcfeats(data, patchSize, hogFeatures);
    

    ////////////////////////////////////
    // Store Centroids, Features (IM) //
    ////////////////////////////////////
    
    NSMutableArray* centroids  = [NSMutableArray array];
    NSMutableArray* features   = [NSMutableArray array];
    
    for (int j = 0; j < patchCount; j++) {
        NSMutableDictionary* stats = [data objectAtIndex:j];
        
        // Centroid
        NSArray* centroid =  [NSArray arrayWithObjects:
                              [stats valueForKey:@"row"],
                              [stats valueForKey:@"col"],
                              nil];
        
        [centroids addObject: centroid];
        
        // Feature
        NSMutableArray* feature = [NSMutableArray arrayWithObjects:
                                   [stats valueForKey:@"phi"],
                                   [stats valueForKey:@"geom"],
                                   nil];
        if (self.hogFeatures) {
            [feature addObject: [stats valueForKey:@"hog"]];
        }
        [features addObject: feature];        
    }
    
    //////////////////////
    // Prepare Features //
    //////////////////////
    
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

    ///////////////////////////////
    // Sort Scores and Centroids //
    ///////////////////////////////
    
    NSMutableArray* sortedScores = [NSMutableArray array];
    [scrs_sort, Isort] = sort(dvtest,'descend');
    ctrs_sort = ctrs(Isort,:);
    
    //////////////////////////////////////
    // Drop Low-confidence Patches (IM) //
    //////////////////////////////////////

    float lowlim = 1e-6;
    NSMutableIndexSet* lowConfidencePatches = [NSMutableIndexSet indexSet];

    for (int i = 0; i < [sortedScores count]; i++) {
        float score = [sortedScores objectAtIndex:i];
        if (i <= lowlim) {
            [lowConfidencePatches addIndex:i];
        }
    }
    [sortedScores removeObjectsAtIndexes:lowConfidencePatches];
    [centroids removeObjectsAtIndexes:lowConfidencePatches];
    
    
    /////////////////////////////////////////
    // Non-max Suppression Based on Scores //
    /////////////////////////////////////////
    
    maxdist = sqrt(size(orig,1)^2 + size(orig,2)^2);
    cp_ctrs_sort = ctrs_sort;
    
    // Setup rows and columns for next step
    NSMutableArray* centroidRows = [NSMutableArray array];
    NSMutableArray* centroidCols = [NSMutableArray array];
    for (int i = 0; i < [centroids count]; i++) {
        NSArray* centroid = [centroids objectAtIndex:i];
        int row = [centroid objectAtIndex:0];
        int col = [centroid objectAtIndex:1];
        [centroidRows addObject:[NSNumber numberWithInt:row]];
        [centroidCols addObject:[NSNumber numberWithInt:col]];
    }
    
    NSMutableIndexSet* suppressedPatches = [NSMutableIndexSet indexSet];
    for (int i = 0; i < [sortedScores count]; i++) { // This should start from the highest-scoring patch
        NSArray* centroid = [centroids objectAtIndex:i];
        int row = [centroid objectAtIndex:0];
        int col = [centroid objectAtIndex:1];
        
        NSArray* rowCopy = [NSArray arrayWithArray:centroidRows];
        NSArray* colCopy = [NSArray arrayWithArray:centroidCols];
        NSMutableArray* distance = [NSMutableArray array];
        for (int j = 0; j < [rowCopy count]; j++;) {
            int newRowVal = row - [rowCopy objectAtIndex: j];
            int newColVal = col - [colCopy objectAtIndex: j];

            newRowVal = newRowVal ** 2;
            newColVal = newColVal ** 2;
            
            float newVal = newRowVal + newColVal;
            newVal = newVal ** 0.5;
            [distance addObject:[NSNumber numberWithFloat:newVal]];
        }
        
        dist(dist==0) = maxdist; // for current patch, artificially elevate so that won't be counted as min
        [mindist,idx] = min(dist); // find closest patch to see if too much overlap
        
        float cutoff = 0.75 * self.patchSize; // non-max suppression parameter, "too close" distance
        if(mindist <= cutoff) { // if too much overlap
            cp_ctrs_sort(idx,1) = -size(orig,1);
            cp_ctrs_sort(idx,2) = -size(orig,2); // prevent triggering non-max again/get rid of lower-score object
        
            // Suppress this patch
            [suppressedPatches addIndex:i];
        }
    }

    [sortedScores removeObjectsAtIndexes:suppressedPatches];
    [centroids removeObjectsAtIndexes:suppressedPatches];
    
    csvwrite(['./out_',fname(1:end-4),'.csv'],[ctrs_sort scrs_sort]);
}

@end
