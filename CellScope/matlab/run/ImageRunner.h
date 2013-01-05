//
//  ImageRunner.h
//  CellScope
//
//  Created by Wayne Gerard on 12/8/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/core/core.hpp>

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
    
}

@property (nonatomic, assign) Mat orig;
@property (nonatomic, assign) int patchSize;
@property (nonatomic, assign) BOOL hogFeatures;

/**
    Runs the image. Stores scores and centroids that pass the low-confidence filter, and returns
    them as a CSV.
    @param img The image to run
 */
- (void) runWithImage: (UIImage*) img;

@end
