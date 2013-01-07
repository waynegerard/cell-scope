//
//  MatrixOperations.mm
//  CellScope
//
//  Created by Wayne Gerard on 1/3/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "MatrixOperations.h"

@implementation MatrixOperations

+ (Mat) zeroes:(int) rows cols:(int) cols {
    return Mat(rows, cols, CV_8UC1, Scalar::all(0));
}

+ (Mat) ones:(int) rows cols:(int) cols {
    return Mat(rows, cols, CV_8UC1, Scalar::all(1));
}

+ (Mat) repMat:(Mat) mat {
    return Mat(0,0,CV_8UC1, Scalar::all(0));
}

+ (id) convertMatToObject:(Mat) mat{
    Mat* ptr = (Mat*)&mat;
    id obj = [NSValue valueWithPointer:ptr];
    return obj;
}

@end