//
//  Region.m
//  CellScope
//
//  Created by Wayne Gerard on 2/25/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Region.h"
#import "Contour.h"
#import <opencv2/imgproc/imgproc.hpp>
using namespace cv;


@implementation Region
@synthesize contours = _contours, img = _img;


+ (NSDictionary*) getRegionPropertiesWithContours:(ContourContainerType) contours withImage:(cv::Mat) img {
    NSDictionary* regionProperties = [NSDictionary dictionary];
    
    // Create the filled image
    Mat filledImage = Mat::zeros(img.rows, img.cols, CV_8UC1);
    drawContours(filledImage, contours, 0, 255, -1);

    // Get the Euler number
    ContourContainerType twoLevel;
    cv::vector<Vec4i> hierarchy;
    
    int holes = 0;
    int total = 0;
    findContours(img, twoLevel, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE);
    
    for (size_t i = 0; i < hierarchy.size(); i++) {
        Vec4i hierarchyVector = hierarchy.at(i);
        if (hierarchyVector[2] != -1) {
            holes++;
        }
        total++;
    }
    
    float eulerNumber = total - holes;
    
    [regionProperties setValue:[NSNumber numberWithFloat:eulerNumber] forKey:@"eulerNumber"];
    
    ContourContainerType::iterator it = contours.begin();
    for (; it != contours.end(); ++it) {
        Contour* contourClass = [[Contour alloc] init];
        [contourClass setContour: *it];
        [contourClass setFilledImage:filledImage];
        [contourClass calculateProperties];
    }
    
    // WAYNE NOTE: This shold only return region properties for the contour closest to the image center
    // Use bounding boxes and calculate euclidean distance to center?
    return regionProperties;
}



@end
