//
//  MatrixOperations.mm
//  CellScope
//
//  Created by Wayne Gerard on 1/3/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "MatrixOperations.h"
#import "highgui.hpp"

@implementation MatrixOperations

+ (Mat) repMat:(Mat) mat withRows:(int) rows withCols:(int) cols{
    int newWidth = rows;
    int newHeight = cols;
    
    Mat newMatrix = Mat(newWidth, newHeight, CV_8UC1);
    
    int left_top_x = 0;
    int left_top_y = 0;
        
    for(; left_top_x < newHeight; left_top_y += (mat.rows))
    {
        if(left_top_y >= newWidth)
        {
            left_top_y = -mat.rows;
            left_top_x += mat.cols;
            continue;
        }
        Mat tileMat = mat(cv::Rect(0, 0, mat.cols, mat.rows));

        cv::Rect newROI = cv::Rect(left_top_x, left_top_y, mat.cols, mat.rows);
        newMatrix(newROI) = tileMat;
    }
    return newMatrix;
}

+ (id) convertMatToObject:(Mat) mat{
    Mat* ptr = (Mat*)&mat;
    id obj = [NSValue valueWithPointer:ptr];
    return obj;
}


@end