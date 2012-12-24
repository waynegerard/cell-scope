//
//  ImageTools.h
//  CellScope
//
//  Created by Wayne Gerard on 12/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/core/core_c.h>

/**
 A variety of small helper functions
 @author Wayne Gerard
 */
@interface ImageTools : NSObject 

/**
    Creates an OpenCV matrix out of a UIImage.
    Attribution: https://github.com/aptogo/OpenCVForiPhone
    @param image The UIImage to be converted
    @return Returns the cv::mat from the converted UIImage
 */
+ (cv::Mat)cvMatWithImage:(UIImage *)image;

@end