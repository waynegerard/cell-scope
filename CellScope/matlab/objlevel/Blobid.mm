//
//  Blobid.m
//  CellScope
//
//  Created by Wayne Gerard on 12/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "Blobid.h"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"


@implementation Blobid

// The morphological open operation is an erosion followed by a dilation, using the same structuring element for both operations.
-(cv::Mat) erodeAndDilateMat: (cv::Mat) mat withSize:(int)sz {
    int type = cv::MORPH_RECT;
    cv::Mat element = cv::getStructuringElement(type, cv::Size(sz,sz));
    cv::Mat returnMat;
    
    cv::erode(mat, returnMat, element);
    cv::dilate(mat, returnMat, element);
    return returnMat;
}

- (cv::Mat) getMorphologicalOpeningWithImg: (cv::Mat) img {

    cv::Mat imBigOp = [self erodeAndDilateMat:img];
    cv::Mat imdf;
    cv::Mat meanImdf;
    cv::Mat stdImdf;
    cv::Mat imThresh;

    cv::subtract(img, imBigOp, imdf);
    cv::meanStdDev(imdf, meanImdf, stdImdf);
    
    imdf = imdf * cv::Scalar_<int>(3);
    cv::add(meanImdf, stdImdf, imThresh);
    return imThresh;    
}


/**
    Simple function that finds blobs in a grayscale image
 */
- (cv::Mat) blobIDWithImage: (cv::Mat&) img {
    
    cv::Mat bwImage;
    cv::Mat imThreshold = [self getMorphologicalOpeningWithImg:img];
    
    // Combine the xcorr and morphological opening outputs
    //imbw = imbw_xcorr & imthresh;
    //imbw = imclose(imbw,strel('square',3));
    return bwImage;
}

@end