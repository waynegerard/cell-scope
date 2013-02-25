//
//  ImageTools.m
//  CellScope
//
//  Created by Wayne Gerard on 12/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "ImageTools.h"
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/highgui/highgui.hpp>

@implementation ImageTools


/**
    Calculates various geometric features provided through regionprops
    @param patch    The patch to calculate geometric features on
    @param binpatch The binary image used to find connected components
    @return         Returns 14 geometric-based features calculated through regionProperties.
 */
+ (Mat)geometricFeaturesWithPatch: (Mat*)patch withBinPatch: (Mat*)binPatch {
    
    Mat* geometricFeatures = new Mat(14, 1, CV_8UC3);
    
    cv::vector<cv::vector<cv::Point> > contours;
    cv::vector<Vec4i> hierarchy;
    
    cv::findContours(binPatch, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE);
    
    if (contours.size() == 0) {
        return cv::Mat::zeros(1, 14, CV_8UC3);
    }
    
    props = regionprops(cc,patch,'all');
    
    % Store features values for object closest to the center of the patch
            geomfeats = [geomfeats...
                         props.Area...           %1
                         props.ConvexArea...     %2
                         props.Eccentricity...   %3
                         props.EquivDiameter...  %4
                         props.Extent...         %5
                         props.FilledArea...     %6
                         props.MajorAxisLength...%7
                         props.MinorAxisLength...%8
                         props.MaxIntensity...   %9
                         props.MinIntensity...   %10
                         props.MeanIntensity...  %11
                         props.Perimeter...      %12
                         props.Solidity...       %13
                         props.EulerNumber];     %14
    end
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
        Mat* geometricFeatures = [self geometricFeaturesWithPatch:patch withBinPatch:binPatch];
        id huPtr = [NSValue valueWithPointer:(Mat*)&huMoments];
        id geomPtr = [NSValue valueWithPointer:geometricFeatures];
        [stats setValue:huPtr forKey: @"phi"];
        [stats setValue:geomPtr forKey:@"geom"];
        [newBlobs addObject:stats];
    }
    return newBlobs;
}
@end
