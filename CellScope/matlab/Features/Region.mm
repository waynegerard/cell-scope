//
//  Region.m
//  CellScope
//
//  Created by Wayne Gerard on 2/25/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Region.h"
#import <opencv2/imgproc/imgproc.hpp>
using namespace cv;


@implementation Region
@synthesize contours = _contours, img = _img;


+ (NSDictionary*) getRegionPropertiesWithContours:(contourContainer) contours withImage:(cv::Mat) img {
    NSDictionary* regionProperties = [NSDictionary dictionary];
    Region* region = [[Region alloc] init];
    return regionProperties;
}



@end
