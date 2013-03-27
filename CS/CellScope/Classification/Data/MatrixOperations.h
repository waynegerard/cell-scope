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

@end
