//
//  MatrixOperations.cpp
//  CellScope
//
//  Created by Wayne Gerard on 1/3/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#include "MatrixOperations.h"


Mat zeroes(int rows, int cols) {
    return Mat(rows, cols, CV_8UC1, Scalar::all(0));
}

Mat ones(int rows, int cols) {
    return Mat(rows, cols, CV_8UC1, Scalar::all(1));
}

Mat repMat(Mat mat) {
    return Mat(0,0,CV_8UC1, Scalar::all(0));
}