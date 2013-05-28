//
//  Debug.h
//  CellScope
//
//  Created by Wayne Gerard on 2/18/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

/**
    A class used for debugging. Mostly pretty print methods.
 */
@interface Debug : NSObject

/**
    Pretty print for matrix.
 */
+ (void) printMatrix:(cv::Mat) mat;

/**
    Pretty print to file.
 */
+ (void) printMatrixToFile:(cv::Mat) mat withRows:(int) rows withCols:(int) cols withName:(NSString*) name;

/**
   Pretty print for array
 */
+ (void) printArrayToFile:(NSMutableArray*) arr withName:(NSString*) name;

+ (void) printMatStats:(cv::Mat) mat;

@end
