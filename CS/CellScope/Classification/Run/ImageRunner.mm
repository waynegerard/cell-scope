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
#import "Patch.h"
#import "imgproc.hpp"

@implementation ImageRunner


@synthesize patchSize = _patchSize, orig = _orig, hogFeatures = _hogFeatures, model = _model;

- (Mat) prepareFeatures
{
    
    /*
    for t = 1:data.NumObjects
        ctrs(t,:) = [data.stats(t).row data.stats(t).col];
    
        if dohog
            feats(t,:) = [data.stats(t).phi data.stats(t).geom data.stats(t).hog];
        else
            feats(t,:) = [data.stats(t).phi data.stats(t).geom];
        end
        binpatches{1,t} = data.stats(t).binpatch;
        patches{1,t} = data.stats(t).patch;
    end
    
    % Prepare features and run object-level classifier
    Xtest = feats;
    ytest_dummy = zeros(size(Xtest,1),1);
    
    % Minmax normalization of features
    maxmat = repmat(train_max,size(ytest_dummy));
    minmat = repmat(train_min,size(ytest_dummy));
    Xtest = (Xtest-minmat)./(maxmat-minmat);
    */
    
    
    // WAYNE:
    // Two problems: repMat is not respecting the rows
    // features should not have 0 columns
    CSLog(@"Preparing features");
    // Minmax normalization of features
    Mat train_max = [DataInteractor loadCSVWithPath:@"train_max"];
    Mat train_min = [DataInteractor loadCSVWithPath:@"train_min"];
    
    int rows = _features->rows;
    int cols = _features->cols;
    Mat maxMatrix = [MatrixOperations repMat:train_max withRows:rows withCols:cols];
    Mat minMatrix = [MatrixOperations repMat:train_min withRows:rows withCols:cols];
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
    [Debug printMatrixToFile:image withRows:90 withCols:90 withName:@"orig"];
    CSLog(@"Image converted successfully to matrix!");
    
    if(!image.data) {
        CSLog(@"Could not load image with filename"); 
        return;
    }
    
    // Convert to a red-channel normalized image if necessary
    if (image.type() == CV_8UC3) {
        image = [ImageTools getRedChannelForImage:image];
    }
    self.orig = [ImageTools getNormalizedImage:image];
    [Debug printMatrixToFile:self.orig withRows:90 withCols:90 withName:@"im2double"];
    // Perform object identification
    Mat imageBw = [Blob blobIdentificationForImage:self.orig];
    
    CSLog(@"Finished object identification");
    ContourContainerType contours;
    cv::vector<Vec4i> hierarchy;
    // ImageBW.type() == 5
    cv::findContours(imageBw, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    
    
    // Get the moments
    CSLog(@"Acquiring Hu moments. Contours size: %zd", contours.size());
    vector<Moments> mu(contours.size() );
    for( int i = 0; i < contours.size(); i++ )
    { mu[i] = moments( contours[i], false ); }
    exit(0);
    
    //  Get the mass centers:
    CSLog(@"Acquiring mass centers")
    NSMutableArray* centroids = [NSMutableArray array];

    vector<Point2f> mc( contours.size() );
    for (int i = 0; i < contours.size(); i++) {
        int x = lroundf(mu[i].m10/mu[i].m00);
        int y = lroundf(mu[i].m01/mu[i].m00);
        CGPoint pt = CGPointMake(x, y);
        [centroids addObject: [NSValue valueWithCGPoint:pt]];
    }
    [Debug printArrayToFile:centroids withName:@"mass_centers_full"];
    exit(0);
    
    _patchCount = 0;
    int numObjects = contours.size();
    
    CSLog(@"Removing partial patches");
    for (int j = 0; j < numObjects; j++) {
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
    [Debug printArrayToFile:data withName:@"centroids_data"];
    exit(0);

    // Calculate features
    data = [ImageTools calcFeaturesWithBlobs:data];
    [Debug printArrayToFile:data withName: @"features"];
    exit(0);
    

    // Store good centroids
    [self storeCentroidsAndFeaturesWithData:data];
    [Debug printMatrixToFile:*_features withRows:_features->rows withCols:_features->cols withName:@"features"];
    
    // Prepare features
    Mat zeroMatrix = Mat::zeros(self.patchSize, 1, CV_8UC1);
    Mat featuresMatrix = [self prepareFeatures];
    [Debug printMatrixToFile:featuresMatrix withRows:featuresMatrix.rows withCols:featuresMatrix.cols withName:@"features_matrix"];
    
    Mat train_max;
    Mat train_min;
    
    // Classify Objects with LibSVM IKSVM classifier
    //svm_predict(<#const struct svm_model *model#>, <#const struct svm_node *x#>);
    //*** NOT WORKING - Waiting on test data*** [pltest, accutest, dvtest] = svmpredict(double(yTest),double(Xtest),model,'-b 1');
    NSMutableArray* dvtest = [NSMutableArray array];
    //*** NOT WORKING  - Waiting on test data*** dvtest = dvtest(:,model.Label==1);
    NSMutableArray* scoreDictionaryArray = [NSMutableArray array];
    
    // Sort Scores and Centroids
    _sortedScores = [self sortScoresWithArray:scoreDictionaryArray];
    
    // Drop Low-confidence Patches
    Patch* patch = [[Patch alloc] init];
    NSMutableIndexSet* lowConfidencePatches = [patch findLowConfidencePatches];
    [_sortedScores removeObjectsAtIndexes:lowConfidencePatches];
    [_centroids removeObjectsAtIndexes:lowConfidencePatches];
    
    // Non-max Suppression Based on Scores
    NSMutableIndexSet* suppressedPatches = [patch findSuppressedPatches];
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
    int columns = (self.hogFeatures) ? 3 : 2;
    _features = new Mat(_patchCount, columns, CV_8UC1);
    
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
