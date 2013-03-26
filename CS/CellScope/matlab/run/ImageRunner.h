//
//  ImageRunner.h
//  CellScope
//
//  Created by Wayne Gerard on 12/8/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

using namespace cv;

@interface ImageRunner : NSObject {
    
    /**
        The red-channel only, normalized image
     */
    Mat _orig;
    
    /**
        The patch size. Assumed to be divisible by 2, otherwise defaults to 24.
     */
    int _patchSize;
    
    /**
        Whether to do HoG features
     */
    BOOL _hogFeatures;
    
    /**
        Centroids for this image
     */
    NSMutableArray* _centroids;
    
    /**
        Features for this image
     */
    Mat* _features;
    
    /**
        The number of patches found for this image
     */
    int _patchCount;
    
    /**
        A list of sorted scores
     */
    NSMutableArray* _sortedScores;
    
}

@property (nonatomic, assign) Mat orig;
@property (nonatomic, assign) int patchSize;
@property (nonatomic, assign) BOOL hogFeatures;

/**
    Drops low confidence patches, defined as patches where the score is less
    than some designated threshold
 
    @return Returns a list of indices of patches that should be dropped
*/
- (NSMutableIndexSet*) findLowConfidencePatches;

/**
    Locates patches that should be suppressed, for being too close to each other
    @return Returns the indices for all patches that should be suppressed
*/
- (NSMutableIndexSet*) findSuppressedPatches;

/**
    Converts an image (as a Mat) to a red-channel only normalized image, with pixel intensities between 0..1
    @param image The image, assumed to be a color image with all 3 channels
    @return      Returns an the red-channel normalized image
*/
- (Mat) getRedImageNormalizedImage: (Mat) image;

/**
    Prepares the features for object classification
*/
- (Mat) prepareFeatures;

/**
    Runs the image. Stores scores and centroids that pass the low-confidence filter, and returns
    them as a CSV.
    @param img The image to run
*/
- (void) runWithImage: (UIImage*) img;

- (NSMutableArray*) sortScoresWithArray:(NSMutableArray*) scoreDictionaryArray;

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
- (NSMutableDictionary*) storeGoodCentroidsWithRow:(int) row withCol:(int) col;

/**
    Stores centroids and features from the data object
    @param data The data object
*/
- (void) storeCentroidsAndFeaturesWithData:(NSMutableArray*) data;

@end
