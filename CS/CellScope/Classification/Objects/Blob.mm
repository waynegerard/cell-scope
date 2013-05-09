//
//  Blob.m
//  CellScope
//
//  Created by Wayne Gerard on 12/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "Blob.h"
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/highgui/highgui.hpp>

using namespace cv;

@implementation Blob

+ (Mat) dilateAndErodeMatrix:(Mat) matrix dilateFirst:(BOOL) dilateFirst withSize:(int) sz {
    CSFNLog(@"Applying dilation and erosion with dilation first: %c", dilateFirst);
    
    int type = MORPH_RECT;
    Mat structuringElement = getStructuringElement(type, cv::Size(sz,sz));
    Mat returnMatrix;
    
    if (dilateFirst) {
        dilate(matrix, returnMatrix, structuringElement);
        erode(matrix, returnMatrix, structuringElement);
    } else {
        erode(matrix, returnMatrix, structuringElement);
        dilate(matrix, returnMatrix, structuringElement);
    }
    
    CSFNLog(@"Finished applying dilation and erosion");
    return returnMatrix;
}

+ (Mat) morphologicalOpeningForMatrix: (Mat) matrix {
    CSFNLog(@"Getting morphological opening");

    Mat imageOpening = [self dilateAndErodeMatrix:matrix dilateFirst:NO withSize:10];
    
    CSFNLog(@"Finished with morphological opening");
    return imageOpening;
}

+ (Mat) crossCorrelateGaussianKernelForMatrix: (Mat) matrix {
    CSFNLog(@"Beginning cross correlation of gaussian kernel with image");
    
    Mat correlationMatrix;
    Mat binarizedMatrix;
    Mat correlationCrop;
    Mat result;
    double* min = new double();
    double* max = new double();
    int kernelSize = 16;               // Size of Gaussian kernel
    float kernelStdDev  = 1.5;         // StdDev of Gaussian kernel
    float correlationThreshold = 0.5;  // Threshold on normalized cross-correlation
    
    // Generate Gaussian kernel
    Mat gaussianKernel = cv::getGaussianKernel(kernelSize, kernelStdDev);
    Mat imageTemplate = cv::Mat(gaussianKernel.rows, gaussianKernel.cols, CV_32F);

    // Convert the template type and match the template to the image
    minMaxIdx(gaussianKernel, min, max);
    divide(*max, gaussianKernel, imageTemplate);
    imageTemplate.convertTo(imageTemplate, CV_32F);
    matchTemplate(matrix, imageTemplate, correlationMatrix, TM_CCORR_NORMED);
    
    // Crop normalized cross correlation image to recover original size, and binarize
    int marginRows = (imageTemplate.rows - 1) / 2;
    int marginCols = (imageTemplate.cols - 1) / 2;
    correlationMatrix = correlationMatrix.rowRange(marginRows + 1, correlationMatrix.rows - marginRows);
    correlationMatrix = correlationMatrix.colRange(marginCols + 1, correlationMatrix.cols - marginCols);
    threshold(correlationMatrix, binarizedMatrix, correlationThreshold, 255.0, CV_THRESH_BINARY);
    
    // Touch-up morphological operations
    int type = cv::MORPH_RECT;
    Mat element = getStructuringElement(type, cv::Size(3,3));
    dilate(binarizedMatrix, result, element);
    
    CSFNLog(@"Finished cross correlation of gaussian kernel with image");
    return result;
}

+ (Mat) blobIdentificationForImage: (Mat) image {
    CSFNLog(@"Beginning blob identification");
    
    Mat grayscaleImage;
    Mat imageThreshold;
    Mat imageDifference;
    Mat meanImageDifference;
    Mat stdDevImageDifference;
    
    Mat imageOpening = [self morphologicalOpeningForMatrix: image];
    subtract(image, imageOpening, imageDifference);
    meanStdDev(imageDifference, meanImageDifference, stdDevImageDifference);
    add(meanImageDifference, stdDevImageDifference, imageThreshold);

    cv::Mat grayscaleCrossCorrelation = [self crossCorrelateGaussianKernelForMatrix: image];
    
    cv::bitwise_and(imageThreshold, grayscaleCrossCorrelation, grayscaleImage);
    grayscaleImage = [self dilateAndErodeMatrix:grayscaleImage dilateFirst:YES withSize:3];
    grayscaleImage.convertTo(grayscaleImage, CV_8UC1);
    
    CSFNLog(@"Finished blob identification");
    return grayscaleImage;
}

@end