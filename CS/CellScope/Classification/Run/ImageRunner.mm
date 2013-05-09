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

#import "Blob.h"
#import "DataInteractor.h"
#import "Debug.h"
#import "ImageRunner.h"
#import "ImageTools.h"
#import "Globals.h"
#import "MatrixOperations.h"

#import "svm.h"
#import "imgproc.hpp"

@implementation ImageRunner


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
    float maxDistance = cv::pow((cv::pow(self.orig.rows, 2.0) + cv::pow(self.orig.cols, 2.0)), 0.5);
    
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
            
            double newVal = newRowVal + newColVal;
            newVal = cv::pow(newVal, 0.5);
            
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
            // Suppress this patch
            [suppressedPatches addIndex:i];
        }
    }
    return suppressedPatches;
}

- (Mat) prepareFeatures
{
    CSLog(@"Preparing features");
    // Minmax normalization of features
    Mat train_max = [DataInteractor loadCSVWithPath:@"train_max"];
    Mat train_min = [DataInteractor loadCSVWithPath:@"train_min"];
        
    Mat maxMatrix = [MatrixOperations repMat:train_max withRows:self.patchSize withCols:1];
    Mat minMatrix = [MatrixOperations repMat:train_min withRows:self.patchSize withCols:1];
    CSLog(@"min and max matrices successfully repeated");
    
    Mat FeaturesMinusMin;
    Mat MaxMinusMin;
    subtract(maxMatrix, minMatrix, MaxMinusMin);
    subtract(*_features, minMatrix, FeaturesMinusMin);
    CSLog(@"min and max matrices successfully subtracted")
    
    
    Mat featuresMatrix = Mat(FeaturesMinusMin.rows, FeaturesMinusMin.cols, CV_8UC1);
    divide(FeaturesMinusMin, MaxMinusMin, featuresMatrix);
    CSLog(@"Leaving prepareFeatures");
    
    return featuresMatrix;
}

- (void) runWithImage: (UIImage*) img
{

    NSMutableArray* data = [NSMutableArray array];

    
    // Convert the image to an OpenCV matrix
    Mat image = [ImageTools cvMatWithImage:img];
    [Debug printMatrixToFile:image withRows:10 withCols:10 withName:@"decimated_loaded_image"];
    CSLog(@"Image converted successfully to matrix!");
    
    if(!image.data) {
        CSLog(@"Could not load image with filename"); 
        return;
    }
    
    if (!self.patchSize) {
        self.patchSize = 16;
    }
    
    // Convert to a red-channel normalized image
    // WAYNE NOTE: this is not necessary for grayscale images. Need something in here.
    //Mat redImage = [ImageTools getRedChannelForImage:image];
    //[Debug printMatrixToFile:redImage withRows:10 withCols:10 withName:@"decimated_red_image"];
    self.orig = [ImageTools getNormalizedImage:image];
    [Debug printMatrixToFile:self.orig withRows:10 withCols:10 withName:@"decimated_normalized_image"];
    
    // Perform object identification
    Mat imageBw = [Blob blobIdentificationForImage:self.orig];
    [Debug printMatrixToFile:imageBw withRows:10 withCols:10 withName:@"decimated_blob_image"];
    
    CSLog(@"Finished object identification");
    ContourContainerType contours;
    cv::vector<Vec4i> hierarchy;
    // ImageBW.type() == 5
    cv::findContours(imageBw, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
    
    // Get the moments
    CSLog(@"Grabbing Hu moments");
    vector<Moments> mu(contours.size() );
    for( int i = 0; i < contours.size(); i++ )
    { mu[i] = moments( contours[i], false ); }
    
    
    //  Get the mass centers:
    NSMutableArray* centroids = [NSMutableArray array];

    vector<Point2f> mc( contours.size() );
    for (int i = 0; i < contours.size(); i++) {
        int x = lroundf(mu[i].m10/mu[i].m00);
        int y = lroundf(mu[i].m01/mu[i].m00);
        CGPoint pt = CGPointMake(x, y);
        [centroids addObject: [NSValue valueWithCGPoint:pt]];
    }
    [Debug printArrayToFile:centroids withName:@"mass_centers_full_1"];
    
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
    data = [ImageTools calcFeaturesWithBlobs:data];
    
    Mat train_max;
    Mat train_min;

    // Store good centroids
    [self storeCentroidsAndFeaturesWithData:data];
    
    // Prepare features
    Mat zeroMatrix = Mat::zeros(self.patchSize, 1, CV_8UC1);
    Mat featuresMatrix = [self prepareFeatures];
    
    // Classify Objects with LibSVM IKSVM classifier
    
    //svm_predict(<#const struct svm_model *model#>, <#const struct svm_node *x#>);
    //*** NOT WORKING - Waiting on test data*** [pltest, accutest, dvtest] = svmpredict(double(yTest),double(Xtest),model,'-b 1');
    NSMutableArray* dvtest = [NSMutableArray array];
    //*** NOT WORKING  - Waiting on test data*** dvtest = dvtest(:,model.Label==1);
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
    [DataInteractor storeScores:_sortedScores withCentroids:_centroids];
}

- (NSMutableArray*) sortScoresWithArray:(NSMutableArray*) scoreDictionaryArray
{
    
    [scoreDictionaryArray sortUsingComparator:^NSComparisonResult(NSMutableDictionary* dictOne, NSMutableDictionary* dictTwo){
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
    
    return stats;
}


@end
