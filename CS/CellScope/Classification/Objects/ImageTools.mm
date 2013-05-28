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

    Mat img_32F(image.rows, image.cols, CV_32F);
    Mat res(image.rows, image.cols, CV_32F);
    
    image.convertTo(img_32F, CV_32F);
    double max;
    double min;
    cv::minMaxIdx(image, &min, &max);
    
    for (int i = 0; i < img_32F.rows; i++) {
        for (int j = 0; j < img_32F.cols; j++) {
            float val = img_32F.at<float>(i, j);
            val = val / max;
            img_32F.at<float>(i, j) = val;
        }
    }
    
    CSLog(@"Image normalized");
    return img_32F;
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
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    Mat cvMat;
    
    if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB) { // 3 channels
        cvMat = Mat(rows, cols, CV_8UC3);
    } else if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome) { // 1 channel
        cvMat = Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    } else {
        CSLog(@"Didnt understand colorspace! %@", colorSpace);
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
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
