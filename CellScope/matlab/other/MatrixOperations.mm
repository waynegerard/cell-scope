//
//  MatrixOperations.mm
//  CellScope
//
//  Created by Wayne Gerard on 1/3/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "MatrixOperations.h"

@implementation MatrixOperations

+ (Mat) repMat:(Mat) mat withRows:(int) rows withCols:(int) cols{
    Mat m = Mat(rows, cols, CV_8UC1);
    
    // Naive implementation for now, copy row and column individually
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            int row = i % mat.rows;
            int col = j % mat.cols;
            float val = mat.at<float>(row, col);
            m.at<float>(i, j) = val;
        }
    }
    return m;
}

+ (id) convertMatToObject:(Mat) mat{
    Mat* ptr = (Mat*)&mat;
    id obj = [NSValue valueWithPointer:ptr];
    return obj;
}

@end