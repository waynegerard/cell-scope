//
//  Runner.m
//  CellScope
//
//  Created by Wayne Gerard on 1/5/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#include "Classifier.h"
#import "Runner.h"
#import "Globals.h"

@implementation Runner

- (cv::Mat)cvMatWithImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat;
    
    if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB) { // 3 channels
        cvMat = cv::Mat(rows, cols, CV_8UC3);
    } else if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome) { // 1 channel
        cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
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


- (void) run {
    
    /////////////////////////////////
    // Handle incorrect parameters //
    /////////////////////////////////
    
    NSDate *start = [NSDate date];
    
    ///////////////////////
    // Choose the images //
    ///////////////////////
    
    // TODO: Let user choose images
    NSMutableArray* images = [NSMutableArray arrayWithCapacity:1];
    UIImage* img = [UIImage imageNamed:@"1350_Clay_Fluor_Yes.png"];
    [images addObject:img];
    int count = [images count];
    
    ////////////////////
    // Run the images //
    ////////////////////
    
    for (int i = 0; i < count; i++) {
        NSLog(@"Processing image %d of %d", i, count);
        UIImage* ui_img = [images objectAtIndex:i];
        cv::Mat converted_img = [self cvMatWithImage:ui_img];
        
        cv::Mat results = Classifier::runWithImage(converted_img);
    }
    
    NSDate *end = [NSDate date];
    NSTimeInterval executionTime = [end timeIntervalSinceDate:start];
    NSLog(@"Execution Time: %f", executionTime);
    
}


@end
