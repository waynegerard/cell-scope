//
//  MatrixOperations.h
//  CellScope
//
//  Created by Wayne Gerard on 1/3/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

using namespace cv;

@interface MatrixOperations : NSObject

/**
    Replication of the repmat function from Matlab. 
    Given a matrix |mat|, rows |r| and cols |c|, copys the matrix into a
    |r| x |c| matrix by tiling the matrix.
    @param mat  The matrix to tile
    @param rows The number of rows in the new matrix
    @param cols The number of cols in the new matrix
    @return     Returns a |rows| x |cols| matrix with tiled copies of |mat|
 */
+ (Mat) repMat:(Mat) mat withRows:(int) rows withCols:(int) cols;

+ (id) convertMatToObject:(Mat) mat;

/**
    A replication of the (matrix) > (val) function in matLab.
    For the given matrix, if the value is > val, returns 1. Else, returns 0.
    Returns a new matrix.
 
    @param compareVal The value to compare matrix values against
    @param mat        The matrix to compare values from
    @return           Returns a copy of |mat|, with all values > val as 1 and all values <= val as 0.
 */
+ (Mat) greaterThanValue:(float) compareVal withMatrix:(Mat) mat;

@end
