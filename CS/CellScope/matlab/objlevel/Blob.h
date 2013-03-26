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

+ (cv::Mat) dilateAndErodeMat: (cv::Mat) mat withSize:(int)sz;

+ (cv::Mat) erodeAndDilateMat: (cv::Mat) mat withSize:(int)sz;

+ (cv::Mat) getMorphologicalOpeningWithImg: (cv::Mat) img;

/**
    Finds blobs in a grayscale image.
    @param img The image, assumed to be grayscale.
    @return Returns
 */
+ (cv::Mat) blobIDWithImage: (const cv::Mat) img;

@end
