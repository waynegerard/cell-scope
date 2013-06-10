//
//  Blob.m
//  CellScope
//
//  Created by Wayne Gerard on 12/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "Blob.h"
#import "Debug.h"
#import "MatrixOperations.h"
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/highgui/highgui.hpp>

using namespace cv;

@implementation Blob

+ (Mat) morphologicalOpeningForMatrix: (Mat) matrix {
    CSFNLog(@"Getting morphological opening");

    Mat element = getStructuringElement(MORPH_RECT, cv::Size(10,10));
    Mat imageOpening = cv::Mat(matrix.rows, matrix.cols, matrix.type());
    cv::morphologyEx(matrix, imageOpening, MORPH_OPEN, element);
    
    CSFNLog(@"Finished with morphological opening");
    return imageOpening;
}

+ (Mat) crossCorrelateGaussianKernelForMatrix: (Mat) matrix {
    CSFNLog(@"Beginning cross correlation of gaussian kernel with image");

    // WAYNE NOTES:
    // 1) Gaussian kernel is 17 x 1, but we need something 17 x 17. how can we get that?
    // 2) is matching the template the same as the normalized cross correlation?
    /*
     %% Generate Gaussian kernel
     G = filterGauss( [Gsz Gsz] + 1, [], [Gstd Gstd].^2);
     template = G/max(G(:));
     C = normxcorr2(template, im);
     
     % Crop normxcorr image to recover original size, binarize
     sztemplate = size(template);
     margin = (sztemplate-1)/2;
     Ccrop = C(margin+1:end-margin,margin+1:end-margin);
     
     Cbin = Ccrop > Cthresh;

     */
    

    Mat correlationMatrix;
    Mat binarizedMatrix;
    Mat correlationCrop;
    Mat result;

    int kernelSize = 17;               // Size of Gaussian kernel // 16 + 1
    float kernelStdDev  = 1.5;         // StdDev of Gaussian kernel
    float correlationThreshold = 0.122;  // Threshold on normalized cross-correlation

    GaussianBlur(matrix, correlationMatrix, cv::Size(kernelSize, kernelSize), kernelStdDev, kernelStdDev);
    [Debug printMatStats:correlationMatrix withFileName:@"gauss_blur_image"];
    
    
//    double* min = new double();
//    double* max = new double();
//
//    // Generate Gaussian kernel
//    Mat gaussianKernel = cv::getGaussianKernel(kernelSize, kernelStdDev);
//    [Debug printMatStats:gaussianKernel withIdentifier:@"gaussianKernel"];
//    [Debug printMatrixToFile:gaussianKernel withRows:10 withCols:10 withName:@"gauss_1"];
//    
//    Mat imageTemplate = cv::Mat(gaussianKernel.rows, gaussianKernel.cols, CV_32F);
//
//    // Convert the template type and match the template to the image
//    minMaxIdx(gaussianKernel, min, max);
//    divide(*max, gaussianKernel, imageTemplate);
//    [Debug printMatStats:imageTemplate withIdentifier:@"imageTemplate1"];
//    [Debug printMatrixToFile:imageTemplate withRows:10 withCols:10 withName:@"gauss_2"];
//
//    imageTemplate.convertTo(imageTemplate, CV_32F);
//    [Debug printMatStats:imageTemplate withIdentifier:@"imageTemplate2"];
//    [Debug printMatrixToFile:imageTemplate withRows:10 withCols:10 withName:@"gauss_3"];
//
//    matchTemplate(matrix, imageTemplate, correlationMatrix, TM_CCORR_NORMED);
//    [Debug printMatStats:correlationMatrix withIdentifier:@"corrMatrix"];
//    [Debug printMatrixToFile:correlationMatrix withRows:10 withCols:10 withName:@"gauss_4"];
    
    // Crop normalized cross correlation image to recover original size, and binarize
//    int marginRows = 1;
//    int marginCols = 1;
    threshold(correlationMatrix, binarizedMatrix, correlationThreshold, 1.0, CV_THRESH_BINARY);
    [Debug printMatStats:binarizedMatrix withFileName:@"binarized_matrix"];
    
    // Touch-up morphological operations
    int type = cv::MORPH_RECT;
    Mat element = getStructuringElement(type, cv::Size(3,3));
    dilate(binarizedMatrix, result, element);
    
    CSFNLog(@"Finished cross correlation of gaussian kernel with image");
    return result;
}

+ (Mat) blobIdentificationForImage: (Mat) image {
    CSFNLog(@"Beginning blob identification");
    
    Mat thresholdCutoff = cv::Mat(1,1, CV_64F);
    Mat grayscaleImage;
    Mat imageThreshold;
    Mat imageDifference;
    Mat meanImageDifference;
    Mat stdDevImageDifference;
    
    Mat imageOpening = [self morphologicalOpeningForMatrix: image];

    subtract(image, imageOpening, imageDifference);
    meanStdDev(imageDifference, meanImageDifference, stdDevImageDifference);
    add(meanImageDifference, stdDevImageDifference, thresholdCutoff);
    add(thresholdCutoff, stdDevImageDifference, thresholdCutoff);
    add(thresholdCutoff, stdDevImageDifference, thresholdCutoff);

    imageThreshold = [MatrixOperations greaterThanValue:thresholdCutoff.at<double>(0,0) withMatrix:imageDifference];
    Mat grayscaleCrossCorrelation = [self crossCorrelateGaussianKernelForMatrix: image];
    bitwise_and(imageThreshold, grayscaleCrossCorrelation, grayscaleImage);

    Mat element = getStructuringElement(MORPH_RECT, cv::Size(3,3));
    cv::morphologyEx(grayscaleImage, grayscaleImage, MORPH_CLOSE, element);
    [Debug printMatrixToFile:grayscaleImage withRows:90 withCols:90 withName:@"imbw"];

    grayscaleImage.convertTo(grayscaleImage, CV_8UC1);
    
    CSFNLog(@"Finished blob identification");
    return grayscaleImage;
}

@end