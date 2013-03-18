//
//  ImageTools.h
//  CellScope
//
//  Created by Wayne Gerard on 12/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

using namespace cv;

/**
 A variety of small helper functions
 @author Wayne Gerard
 */
@interface ImageTools : NSObject 

/**
    Calculates various geometric features provided through regionprops
    @param patch    The patch to calculate geometric features on
    @param binpatch The binary image used to find connected components
    @return         Returns 14 geometric-based features calculated through regionProperties.
 */
+ (Mat)geometricFeaturesWithPatch: (Mat*)patch withBinPatch: (Mat*)binPatch;

/**
    Creates an OpenCV matrix out of a UIImage.
    Attribution: https://github.com/aptogo/OpenCVForiPhone
    @param image The UIImage to be converted
    @return Returns the cv::mat from the converted UIImage
 */
+ (Mat)cvMatWithImage:(UIImage *)image;

/**
    Calculates the Hu moments and geometric features of an array of blobs.
    @param blobs An array of NSDictionaries, containing information about that blob
    @return      Returns, for each blob, a dictionary containing the hu moments and geometric features for that blob
 */
+ (NSMutableArray*) calcFeaturesWithBlobs: (NSMutableArray*) blobs;

@end
