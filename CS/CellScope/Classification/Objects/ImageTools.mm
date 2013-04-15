//
//  ImageTools.m
//  CellScope
//
//  Created by Wayne Gerard on 12/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "ImageTools.h"
#import "Region.h"
#import "imgproc.hpp"

@implementation ImageTools

+ (Mat) getRedChannelForImage: (Mat) image {
    CSLog(@"Starting conversion to red normalized image");
    
    Mat red(image.rows, image.cols, CV_8UC1);
    Mat junk(image.rows, image.cols, CV_8UC2);
    
    Mat output[] = { red, junk };
    int index_map[] = { 0,0, 1,1, 2,2 };
    mixChannels(&image, 1, output, 2, index_map, 3);
    
    CSLog(@"Red channel conversion complete");
    return red;
}


+ (Mat) getNormalizedImage: (Mat) image {
    
    CSLog(@"Normalizing image");
    
    // Normalize the image to values between 0..1
    Mat orig = Mat(image.rows, image.cols, CV_32F);
    Mat img_32F(image.rows, image.cols, CV_32F);
    convertScaleAbs(image, img_32F);
    normalize(img_32F, orig, 0, NORM_MINMAX);
    
    CSLog(@"Image normalized");
    return orig;
}



+ (Mat)geometricFeaturesWithPatch: (Mat*)patch withBinPatch: (Mat*)binPatch {
    
    Mat geometricFeatures = Mat(14, 1, CV_8UC3);

    ContourContainerType contours;
    cv::vector<Vec4i> hierarchy;

    findContours(*binPatch, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
    if (contours.size() == 0) {
        return cv::Mat::zeros(14, 1, CV_8UC3);
    }
    
    NSDictionary* regionProperties = [Region getCenterContourProperties:contours withImage:*binPatch];
    NSArray* keys = [NSArray arrayWithObjects:@"area", @"convexArea", @"eccentricity",
                     @"equivDiameter", @"extent", @"filledArea", @"minorAxisLength",
                     @"majorAxisLength", @"maxIntensity", @"minIntensity", @"meanIntensity",
                     @"perimeter", @"solidity", @"eulerNumber", nil];

    for (int i = 0; i < keys.count; i++) {
        geometricFeatures.at<float>(0, i) = [[regionProperties valueForKey:[keys objectAtIndex:i]] floatValue];
    }
    
    
    return geometricFeatures;    
}

+ (Mat)cvMatWithImage:(UIImage *)image
{
    CSLog(@"Starting conversion of image to Mat process... ");
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    CSLog(@"Image columns: %f Image rows: %f", cols, rows);
    
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

+ (NSMutableArray*) calcFeaturesWithBlobs: (NSMutableArray*) blobs {

    NSMutableArray* newBlobs = [NSMutableArray array];
    for (int i = 0; i < [blobs count]; i++) {
        NSMutableDictionary* stats = [blobs objectAtIndex:i];
        Mat* patch = (__bridge Mat*) [stats valueForKey:@"patch"];
        
        // Calculate the hu moments
        Moments m = cv::moments(*patch);
        Mat huMoments;
        HuMoments(m, huMoments);
        
        // Grab the geometric features and return
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