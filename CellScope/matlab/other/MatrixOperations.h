//
//  MatrixOperations.h
//  CellScope
//
//  Created by Wayne Gerard on 1/3/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/core/core.hpp>

using namespace cv;

@interface MatrixOperations : NSObject

+ (Mat) zeroes:(int) rows cols:(int) cols;

+ (Mat) ones:(int) rows cols:(int) cols;

+ (Mat) repMat:(Mat) mat;

+ (id) convertMatToObject:(Mat) mat;

@end
