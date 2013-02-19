//
//  Debug.m
//  CellScope
//
//  Created by Wayne Gerard on 2/18/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Debug.h"

@implementation Debug

+ (void) printMatrix:(cv::Mat) mat {

    int rows = mat.rows;
    int cols = mat.cols;
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            float val = mat.at<float>(i, j);
            NSLog(@"Value at %d, %d: %f", i, j, val);
        }
    }
}

@end
