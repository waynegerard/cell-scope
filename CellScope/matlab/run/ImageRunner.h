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
    Mat orig;
    
    /**
        The patch size. Assumed to be divisible by 2, otherwise defaults to 24.
     */
    int patchSize;
    
    /**
        Whether to do HoG features
     */
    BOOL hogFeatures;
    
}

@end
