//
//  MatrixOperations.h
//  CellScope
//
//  Created by Wayne Gerard on 1/3/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#ifndef __CellScope__MatrixOperations__
#define __CellScope__MatrixOperations__

#include <iostream>
#include <opencv2/core/core.hpp>

using namespace cv;

Mat zeroes(int rows, int cols);

Mat ones(int rows, int cols);

Mat repMat(Mat mat);

#endif /* defined(__CellScope__MatrixOperations__) */
