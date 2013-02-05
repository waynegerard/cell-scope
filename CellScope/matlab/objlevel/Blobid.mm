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

- (cv::Mat) dilateAndErodeMat: (cv::Mat) mat withSize:(int)sz {
    int type = cv::MORPH_RECT;
    cv::Mat element = cv::getStructuringElement(type, cv::Size(sz,sz));
    cv::Mat returnMat;
    
    cv::dilate(mat, returnMat, element);
    cv::erode(mat, returnMat, element);
    return returnMat;
}


- (cv::Mat) erodeAndDilateMat: (cv::Mat) mat withSize:(int)sz {
    int type = cv::MORPH_RECT;
    cv::Mat element = cv::getStructuringElement(type, cv::Size(sz,sz));
    cv::Mat returnMat;
    
    cv::erode(mat, returnMat, element);
    cv::dilate(mat, returnMat, element);
    return returnMat;
}

- (cv::Mat) getMorphologicalOpeningWithImg: (cv::Mat) img {

    cv::Mat imBigOp = [self erodeAndDilateMat:img withSize:10];
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

// Cross correlates image "orig" with a Gaussian kernel

- (cv::Mat) xCorrGaussWithImg: (cv::Mat) img {
    
    // Parameters
    int kernelSize = 16 + 1;       // size of Gaussian kernel
    // WAYNE NOTE: Why is there a +1 in the original?
    float kernelStdDev  = 1.5;     // standard dev of Gaussian kernel
    float correlationThreshold = 0.5; // threshold on normalized cross-correlation
    cv::Mat tmplate;
    
    // Generate Gaussian kernel
    cv::Mat gaussianKernel = cv::getGaussianKernel(kernelSize, kernelStdDev);
    double* min;
    double* max;
    cv::minMaxIdx(gaussianKernel, min, max);
    cv::divide(*max, gaussianKernel, tmplate);
    C = normxcorr2(template, im);
    
    // Crop normxcorr image to recover original size, binarize
    sztemplate = size(template);
    margin = (sztemplate-1)/2;
    Ccrop = C(margin+1:end-margin,margin+1:end-margin);
    Cbin = Ccrop > Cthresh;
    
    // Touch-up morphological operations
    int type = cv::MORPH_RECT;
    cv::Mat returnMat;
    cv::Mat element = cv::getStructuringElement(type, cv::Size(3,3));
    cv::dilate(cBin, returnMat, element);
    return returnMat;
}

- (cv::Mat) blobIDWithImage: (cv::Mat&) img {
    
    cv::Mat bwImage;
    cv::Mat xCorrImage;
    cv::Mat imThreshold = [self getMorphologicalOpeningWithImg:img];
    
    imbw_xcorr = [self xCorrGaussWithImg:img];

    // Combine the xcorr and morphological opening output
    
    // The morphological close operation is a dilation followed by an erosion,
    // using the same structuring element for both operations.
    cv::bitwise_and(imThreshold, xCorrImage, bwImage);
    bwImage = [self dilateAndErodeMat:bwImage withSize:3];
    return bwImage;
}

@end