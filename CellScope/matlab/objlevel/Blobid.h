//
//  Blobid.h
//  CellScope
//
//  Created by Wayne Gerard on 12/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/core/core.hpp>

@interface Blobid : NSObject

+ (cv::Mat) dilateAndErodeMat: (cv::Mat) mat withSize:(int)sz;

+ (cv::Mat) erodeAndDilateMat: (cv::Mat) mat withSize:(int)sz;

+ (cv::Mat) getMorphologicalOpeningWithImg: (cv::Mat) img;

/**
 Simple function that finds blobs in a grayscale image
 */
+ (cv::Mat) blobIDWithImage: (const cv::Mat) img;

@end
