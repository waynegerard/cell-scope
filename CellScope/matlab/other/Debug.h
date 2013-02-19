//
//  Debug.h
//  CellScope
//
//  Created by Wayne Gerard on 2/18/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <opencv2/core/core.hpp>

/**
    A class used for debugging. Mostly pretty print methods.
 */
@interface Debug : NSObject

/**
    Pretty print for matrix.
 */
+ (void) printMatrix:(cv::Mat) mat;

@end
