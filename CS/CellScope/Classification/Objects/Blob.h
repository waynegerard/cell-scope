//
//  Blob.h
//  CellScope
//
//  Created by Wayne Gerard on 12/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

@interface Blob : NSObject

/**
    Applies the dilation and erosion procedure to a matrix.
 
    @param matrix      The matrix to apply the operation to
    @param dilateFirst Whether to dilate first and erode second, or the other way around
    @param sz          The size of the structuring element
    @return            Returns the matrix with the dilation/erosion operations applied
 */
+ (cv::Mat) dilateAndErodeMatrix:(cv::Mat) matrix dilateFirst:(BOOL) dilateFirst withSize:(int) sz;

/**
    Gets the morphological opening for the matrix
 
    @param matrix The matrix to get the morphological opening for
    @return       Returns the morphological opening for the matrix
 */
+ (cv::Mat) morphologicalOpeningForMatrix: (cv::Mat) matrix;

/**
    Cross correlates the given matrix with a generated gaussian kernel
 
    @param matrix The matrix to cross correlate with a generated gaussian kernel
    @return       The matrix after having been cross-correlized
 */
+ (cv::Mat) crossCorrelateGaussianKernelForMatrix: (cv::Mat) matrix;

/**
    Identifies blobs in the given image.
    
    @param image The image to identify blobs in
    @return      The image (grayscale) with only blobs
 */
+ (cv::Mat) blobIdentificationForImage: (cv::Mat) image;

@end
