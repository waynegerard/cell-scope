//
//  ImageTools.m
//  CellScope
//
//  Created by Wayne Gerard on 12/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "ImageTools.h"
#import "Region.h"

@implementation ImageTools


/**
    Calculates various geometric features provided through regionprops
    @param patch    The patch to calculate geometric features on
    @param binpatch The binary image used to find connected components
    @return         Returns 14 geometric-based features calculated through regionProperties.
 */
+ (Mat)geometricFeaturesWithPatch: (Mat*)patch withBinPatch: (Mat*)binPatch {
    
    Mat geometricFeatures = Mat(14, 1, CV_8UC3);

    ContourContainerType contours;
    cv::vector<Vec4i> hierarchy;

    findContours(*binPatch, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
    if (contours.size() == 0) {
        return cv::Mat::zeros(14, 1, CV_8UC3);
    }
    
    NSDictionary* regionProperties = [Region getCenterContourProperties:contours withImage:*binPatch];
    NSArray* keys = [NSArray arrayWithObjects:@"area", @"convexArea", "eccentricity", "equivDiameter",
                     @"extent", @"filledArea", @"minorAxisLength", @"majorAxisLength", @"maxIntensity",
                     @"minIntensity", @"meanIntensity", @"perimeter", @"solidity", @"eulerNumber", nil];

    for (int i = 0; i < keys.count; i++) {
        geometricFeatures.at<float>(0, i) = [[regionProperties valueForKey:[keys objectAtIndex:i]] floatValue];
    }
    
    
    return geometricFeatures;    
}

+ (Mat)cvMatWithImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    Mat cvMat(rows, cols, CV_8UC3); // 8 bits per component, 3 channels (RGB)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

/**
 CALCFEATS takes the patches and calculates various Hu moments, geometric,
 and photometric features
 */
+ (NSMutableArray*) calcFeaturesWithBlobs: (NSMutableArray*) blobs withPatchSize:(int) patchSize {

    NSMutableArray* newBlobs = [NSMutableArray array];
    for (int i = 0; i < [blobs count]; i++) {
        NSMutableDictionary* stats = [blobs objectAtIndex:i];
        Mat* patch = (__bridge Mat*) [stats valueForKey:@"patch"];
        
        // Calculate the hu moments
        Moments m = cv::moments(*patch);
        Mat huMoments;
        HuMoments(m, huMoments);
        
        Mat* binPatch = (__bridge Mat*) [stats valueForKey:@"binpatch"];
        Mat geometricFeatures = [self geometricFeaturesWithPatch:patch withBinPatch:binPatch];
        id huPtr = [NSValue valueWithPointer:(Mat*)&huMoments];
        id geomPtr = [NSValue valueWithPointer:(Mat*)&geometricFeatures];
        [stats setValue:huPtr forKey: @"phi"];
        [stats setValue:geomPtr forKey:@"geom"];
        [newBlobs addObject:stats];
    }
    return newBlobs;
}
@end
