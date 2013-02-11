//
//  ImageTools.m
//  CellScope
//
//  Created by Wayne Gerard on 12/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "ImageTools.h"
#import <opencv2/imgproc/imgproc.hpp>

@implementation ImageTools


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
+ (Mat) calcFeaturesWithBlobs: (NSMutableArray*) blobs withPatchSize:(int) patchSize {

    for (int i = 0; i < [blobs count]; i++) {
        // Stats is a NSMutabledictionary
        NSMutableDictionary* stats = [blobs objectAtIndex:i];
        NSNumber moment = [self huMomentForPatch: patch];
        Mat binPatch = [stats valueForKey:@"binpatch"];
        NSNumber geom = [self geomWithPatch: patch withBinaryPatch: binPatch];
        [stats setValue:moment forKey: @"phi" ];
        [stats setValue:geom forKey:@"geom"];
        
    }
}
@end
