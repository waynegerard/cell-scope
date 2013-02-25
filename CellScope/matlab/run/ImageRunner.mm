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

#import "Blobid.h"
#import "ImageRunner.h"
#import "ImageTools.h"
#import "Globals.h"
#import "MatrixOperations.h"
#import "svm.h"
#import <opencv2/imgproc/imgproc.hpp>

@implementation ImageRunner

// TODO:
// train_max, train_min
// svmpredict


@synthesize patchSize = _patchSize, orig = _orig, hogFeatures = _hogFeatures;

- (NSMutableIndexSet*) findLowConfidencePatches
{
    float lowlim = 1e-6;
    NSMutableIndexSet* lowConfidencePatches = [NSMutableIndexSet indexSet];
    
    for (int i = 0; i < [_sortedScores count]; i++) {
        float score = [[_sortedScores objectAtIndex:i] floatValue];
        if (score <= lowlim) {
            [lowConfidencePatches addIndex:i];
        }
    }
    return lowConfidencePatches;
}

- (NSMutableIndexSet*) findSuppressedPatches
{
    float maxDistance = pow((pow(self.orig.rows, 2) + cv::pow(self.orig.cols, 2)), 0.5);
    
    // Setup rows and columns for next step
    NSMutableArray* centroidRows = [NSMutableArray array];
    NSMutableArray* centroidCols = [NSMutableArray array];
    for (int i = 0; i < [_centroids count]; i++) {
        NSArray* centroid = [_centroids objectAtIndex:i];
        int row = [[centroid objectAtIndex:0] intValue];
        int col = [[centroid objectAtIndex:1] intValue];
        [centroidRows addObject:[NSNumber numberWithInt:row]];
        [centroidCols addObject:[NSNumber numberWithInt:col]];
    }
    
    NSMutableIndexSet* suppressedPatches = [NSMutableIndexSet indexSet];
    for (int i = 0; i < [_sortedScores count]; i++) { // This should start from the highest-scoring patch
        NSArray* centroid = [_centroids objectAtIndex:i];
        int row = [[centroid objectAtIndex:0] intValue];
        int col = [[centroid objectAtIndex:1] intValue];
        
        NSArray* rowCopy = [NSArray arrayWithArray:centroidRows];
        NSArray* colCopy = [NSArray arrayWithArray:centroidCols];
        NSMutableArray* distance = [NSMutableArray array];
        
        float minDistance = 1e99;
        int minDistanceIndex = -1;
        
        for (int j = 0; j < [rowCopy count]; j++) {
            int newRowVal = row - [[rowCopy objectAtIndex: j] intValue];
            int newColVal = col - [[colCopy objectAtIndex: j] intValue];
            
            newRowVal = pow(newRowVal, 2.0);
            newColVal = pow(newColVal, 2.0);
            
            float newVal = newRowVal + newColVal;
            newVal = pow(newVal, 0.5);
            
            if (newVal < minDistance && newVal != 0) {
                minDistance = newVal;
                minDistanceIndex = j;
            }
            
            
            [distance addObject:[NSNumber numberWithFloat:newVal]];
        }
        
        // Find the patch with the minimum distance (that isn't the current patch, where distance == 0)
        
        // See if it's too close. If it is, then suppress the patch
        float cutoff = 0.75 * self.patchSize; // non-max suppression parameter, "too close" distance
        if(minDistance <= cutoff) { // if too much overlap
            // WG Note: Why is this necessary again?
            // prevent triggering non-max again/get rid of lower-score object
            NSArray* newCentroid = [NSArray arrayWithObjects:
                                    [NSNumber numberWithInt:(-1 * self.orig.rows)],
                                    [NSNumber numberWithInt:(-1 * self.orig.cols)],
                                    nil];
            // Suppress this patch
            [suppressedPatches addIndex:i];
        }
    }
    return suppressedPatches;
}


- (Mat) getRedImageNormalizedImage: (Mat) image {
    // ASK: Is this right?
    // Use only red channel for image
    
    // WN: I have no idea if this is the right thing to be doing
    // This seems to suggest so: http://www.cs.bc.edu/~hjiang/c335/notes/lec3/lec3.pdf
    Mat red(image.rows, image.cols, CV_8UC1);
    Mat green(image.rows, image.cols, CV_8UC1);
    Mat blue(image.rows, image.cols, CV_8UC1);
    cvSplit(&image, &red, &green, &blue, 0);
    
    // TODO: Converting to red channel right now, is that correct? Check back with Mike and Arunan
    // Normalize the image to values between 0..1
    Mat orig = Mat(image.rows, image.cols, CV_32F);
    Mat red_32F(image.rows, image.cols, CV_32F);
    convertScaleAbs(red, red_32F);
    cvNormalize(&orig, &red_32F);
    normalize(red_32F, orig, 0, NORM_MINMAX);
    return orig;
}

- (Mat) prepareFeatures
{
    // Minmax normalization of features
    Mat maxMatrix = [MatrixOperations repMat:train_max withRows:self.patchSize withCols:1];
    Mat minMatrix = [MatrixOperations repMat:train_min withRows:self.patchSize withCols:1];
    
    Mat FeaturesMinusMin;
    Mat MaxMinusMin;
    subtract(maxMatrix, minMatrix, MaxMinusMin);
    subtract(*_features, minMatrix, FeaturesMinusMin);
    
    Mat Xtest = Mat(FeaturesMinusMin.rows, FeaturesMinusMin.cols, CV_8UC1);
    divide(FeaturesMinusMin, MaxMinusMin, Xtest);
    return Xtest;
}

- (void) runWithImage: (UIImage*) img
{
    // Convert the image to an OpenCV matrix
    Mat image = [ImageTools cvMatWithImage:img];
    if(!image.data) // IM
    {
        CSLog(@"Could not load image with filename"); 
        return;
    }
    
    // Convert to a red-channel normalized image
    self.orig = [self getRedImageNormalizedImage:image];
    NSMutableArray* data = [NSMutableArray array];
    
    // Perform object identification
    cv::Mat imageBw = [Blobid blobIDWithImage:(self.orig)]; // Use Gaussian kernel method
        
    cv::vector<cv::vector<cv::Point> > contours;
    cv::vector<Vec4i> hierarchy;
    
    cv::findContours(imageBw, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE);
    
    /// Get the moments
    vector<Moments> mu(contours.size() );
    for( int i = 0; i < contours.size(); i++ )
    { mu[i] = moments( contours[i], false ); }
    
    ///  Get the mass centers:
    NSMutableArray* centroids = [NSMutableArray array];

    vector<Point2f> mc( contours.size() );
    for (int i = 0; i < contours.size(); i++) {
        int x = lroundf(mu[i].m10/mu[i].m00);
        int y = lroundf(mu[i].m01/mu[i].m00);
        CGPoint pt = CGPointMake(x, y);
        [centroids addObject: [NSValue valueWithCGPoint:pt]];
    }
    
    // Computer gradient image for HoG features
    
    _patchCount = 0;
    
    int numObjects = contours.size();
    
    for (int j = 0; j < numObjects; j++) { // IM
        NSValue* val = [centroids objectAtIndex:j];
        CGPoint pt = [val CGPointValue];
        int col = pt.x;
        int row = pt.y;
        
        NSMutableDictionary* stats  = [self storeGoodCentroidsWithRow:row withCol:col];
        if (stats != NULL) { // If not a partial patch
            _patchCount++;
            [data addObject:stats];
            
        }
    }
    
    // Calculate features
    data = [ImageTools calcFeaturesWithBlobs:data withPatchSize:self.patchSize];
    
    Mat train_max;
    Mat train_min;

    // Store good centroids
    [self storeCentroidsAndFeaturesWithData:data];
    
    // Prepare features
    Mat yTest = Mat::zeros(self.patchSize, 1, CV_8UC1);
    Mat xTest = [self prepareFeatures];
    
    // Classify Objects with LibSVM IKSVM classifier
    
    //svm_predict(<#const struct svm_model *model#>, <#const struct svm_node *x#>);
    //*** NOT WORKING *** [pltest, accutest, dvtest] = svmpredict(double(yTest),double(Xtest),model,'-b 1');
    NSMutableArray* dvtest = [NSMutableArray array];
    //*** NOT WORKING *** dvtest = dvtest(:,model.Label==1);
    NSMutableArray* scoreDictionaryArray = [NSMutableArray array];
    
    // Sort Scores and Centroids
    _sortedScores = [self sortScoresWithArray:scoreDictionaryArray];
    
    // Drop Low-confidence Patches
    NSMutableIndexSet* lowConfidencePatches = [self findLowConfidencePatches];
    [_sortedScores removeObjectsAtIndexes:lowConfidencePatches];
    [_centroids removeObjectsAtIndexes:lowConfidencePatches];
    
    // Non-max Suppression Based on Scores
    NSMutableIndexSet* suppressedPatches = [self findSuppressedPatches];
    [_sortedScores removeObjectsAtIndexes:suppressedPatches];
    [_centroids removeObjectsAtIndexes:suppressedPatches];
    
    // Output
    [self writeToCoreData];
}

- (NSMutableArray*) sortScoresWithArray:(NSMutableArray*) scoreDictionaryArray
{
    [scoreDictionaryArray sortUsingComparator:^(NSMutableDictionary* dictOne, NSMutableDictionary* dictTwo){
        float score1 = [[dictOne valueForKey:@"value"] floatValue];
        float score2 = [[dictTwo valueForKey:@"value"] floatValue];
        if (score1 < score2)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
    
    // Now sortedDictionaryArray is sorted in descending order
    // Sort sortedScores and centroids using the indices attached to the sortedDictionaryArray
    
    NSMutableArray* sortedScores = [NSMutableArray array];
    
    for (int i = 0; i < [sortedScores count]; i++) {
        NSMutableDictionary* score = [sortedScores objectAtIndex:i];
        NSNumber* value = [score valueForKey:@"value"];
        int index = [[score valueForKey:@"index"] intValue];
        
        NSNumber* oldObject = [_centroids objectAtIndex:i];
        NSNumber* sortedObject = [_centroids objectAtIndex:index];
        
        [_centroids replaceObjectAtIndex:index withObject:oldObject];
        [_centroids replaceObjectAtIndex:i withObject:sortedObject];
        [sortedScores addObject:value];
        
    }
    return sortedScores;
}

- (void) storeCentroidsAndFeaturesWithData:(NSMutableArray*) data
{
    
    _centroids  = [NSMutableArray array];
    
    Mat feature_mat;
    if (self.hogFeatures) {
        feature_mat = Mat(_patchCount, 3, CV_8UC1);
    } else {
        feature_mat = Mat(_patchCount, 2, CV_8UC1);
    }
    _features = (Mat*) &feature_mat;
    
    for (int j = 0; j < _patchCount; j++) {
        NSMutableDictionary* stats = [data objectAtIndex:j];
        
        NSArray* centroid =  [NSArray arrayWithObjects:
                              [stats valueForKey:@"row"],
                              [stats valueForKey:@"col"],
                              nil];
        
        [_centroids addObject: centroid];
        
        
        _features->at<float>(j, 0) = [[stats valueForKey:@"phi"] floatValue];
        _features->at<float>(j, 1) = [[stats valueForKey:@"geom"] floatValue];
        
        if (self.hogFeatures) {
            _features->at<float>(j, 2) = [[stats valueForKey:@"hog"] floatValue];
        }
    }
    
}

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


- (void) writeToCoreData
{
    // TODO: Implement
}

@end
