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

    int kernelSize = 16;               // Size of Gaussian kernel // 16 + 1
    float kernelStdDev  = 1.5 * 1.5;         // StdDev of Gaussian kernel
    float correlationThreshold = 0.5;  // Threshold on normalized cross-correlation
    
    Mat correlationMatrix;
    Mat binarizedMatrix;
    Mat correlationCrop;
    Mat result;
    double* min = new double();
    double* max = new double();

    // Generate Gaussian kernel
    Mat gaussianKernel = cv::getGaussianKernel(kernelSize, kernelStdDev);
    [Debug printMatStats:gaussianKernel];
    [Debug printMatrixToFile:gaussianKernel withRows:10 withCols:10 withName:@"gauss_1"];
    
    Mat imageTemplate = cv::Mat(gaussianKernel.rows, gaussianKernel.cols, CV_32F);
    
    // Convert the template type and match the template to the image
    minMaxIdx(gaussianKernel, min, max);
    divide(*max, gaussianKernel, imageTemplate);
    [Debug printMatStats:imageTemplate];
    [Debug printMatrixToFile:imageTemplate withRows:10 withCols:10 withName:@"gauss_2"];

    imageTemplate.convertTo(imageTemplate, CV_32F);
    [Debug printMatStats:imageTemplate];
    [Debug printMatrixToFile:imageTemplate withRows:10 withCols:10 withName:@"gauss_3"];

    matchTemplate(matrix, imageTemplate, correlationMatrix, TM_CCORR_NORMED);
    [Debug printMatStats:correlationMatrix];
    [Debug printMatrixToFile:correlationMatrix withRows:10 withCols:10 withName:@"gauss_4"];
    
    // Crop normalized cross correlation image to recover original size, and binarize
    int marginRows = (imageTemplate.rows - 1) / 2;
    int marginCols = (imageTemplate.cols - 1) / 2;
    correlationMatrix = correlationMatrix.rowRange(marginRows + 1, correlationMatrix.rows - marginRows);
    [Debug printMatStats:correlationMatrix];
    [Debug printMatrixToFile:correlationMatrix withRows:10 withCols:10 withName:@"gauss_5"];
    correlationMatrix = correlationMatrix.colRange(marginCols + 1, correlationMatrix.cols - marginCols);
    [Debug printMatStats:correlationMatrix];
    [Debug printMatrixToFile:correlationMatrix withRows:100 withCols:100 withName:@"gauss_6"];
    threshold(correlationMatrix, binarizedMatrix, correlationThreshold, 1.0, CV_THRESH_BINARY);
    [Debug printMatStats:binarizedMatrix];
    [Debug printMatrixToFile:binarizedMatrix withRows:100 withCols:100 withName:@"gauss_7"];
    
    // Touch-up morphological operations
    int type = cv::MORPH_RECT;
    Mat element = getStructuringElement(type, cv::Size(3,3));
    dilate(binarizedMatrix, result, element);
    [Debug printMatStats:result];
    [Debug printMatrixToFile:result withRows:10 withCols:10 withName:@"gauss_8"];
    
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
    
    /*
    imbigop=imopen(orig,strel('square',10));%strel('disk',10)
    imdf=orig-imbigop;
    imthresh=imdf>(mean(imdf(:)) + 3*std(imdf(:)));
    */
    
    Mat imageOpening = [self morphologicalOpeningForMatrix: image];
    subtract(image, imageOpening, imageDifference);
    meanStdDev(imageDifference, meanImageDifference, stdDevImageDifference);
    add(meanImageDifference, stdDevImageDifference, thresholdCutoff);
    imageThreshold = [MatrixOperations greaterThanValue:thresholdCutoff.at<double>(0,0) withMatrix:imageDifference];

    Mat grayscaleCrossCorrelation = [self crossCorrelateGaussianKernelForMatrix: image];
    [Debug printMatStats:grayscaleCrossCorrelation];
    [Debug printMatrixToFile:grayscaleCrossCorrelation withRows:10 withCols:10 withName:@"blob_6"];
    
    bitwise_and(imageThreshold, grayscaleCrossCorrelation, grayscaleImage);
    [Debug printMatStats:grayscaleImage];
    [Debug printMatrixToFile:grayscaleImage withRows:10 withCols:10 withName:@"blob_7"];

    grayscaleImage = [self dilateAndErodeMatrix:grayscaleImage dilateFirst:YES withSize:3];
    [Debug printMatStats:grayscaleImage];
    [Debug printMatrixToFile:grayscaleImage withRows:10 withCols:10 withName:@"blob_8"];

    grayscaleImage.convertTo(grayscaleImage, CV_8UC1);
    [Debug printMatStats:grayscaleImage];
    [Debug printMatrixToFile:grayscaleImage withRows:10 withCols:10 withName:@"blob_9"];
    
    CSFNLog(@"Finished blob identification");
    exit(0);
    return grayscaleImage;
}

@end