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

+ (Mat) greaterThanValue:(float) compareVal withMatrix:(Mat) mat {
    Mat parsedMatrix = Mat(mat.rows, mat.cols, mat.type());
    
    for (int i = 0; i < mat.rows; i++) {
        for (int j = 0; j < mat.cols; j++) {
            if (mat.type() == CV_32F) {
                float val = mat.at<float>(i, j);
                float newVal = val > compareVal ? 1 : 0;
                parsedMatrix.at<float>(i, j) = newVal;
            } else if (mat.type() == CV_64F) {
                double val = mat.at<double>(i, j);
                double newVal = val > compareVal ? 1 : 0;
                parsedMatrix.at<double>(i, j) = newVal;
            } else if (mat.type() == CV_8UC1) {
                int val = (int)mat.at<uchar>(i, j);
                int newVal = val > compareVal ? 1 : 0;
                parsedMatrix.at<int>(i, j) = newVal;
            } else {
                CSLog(@"Didnt understand matrix type: %d", mat.type());
            }
        }
    }
    
    return parsedMatrix;
}


@end