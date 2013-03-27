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


+ (NSDictionary*) getCenterContourProperties:(ContourContainerType) contours withImage:(cv::Mat) img {
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
    
    // Calculate the contour closest to the center of the image, using bounding rectangles
    ContourContainerType::iterator it = contours.begin();
    float xCenter = img.cols / 2.0;
    float yCenter = img.rows / 2.0;
    float currentDistance = 1E99;
    ContourType centerCountour;
    for (; it != contours.end(); ++it) {
        cv::Rect boundingRect = cv::boundingRect(*it);
        float x = boundingRect.x + (boundingRect.width / 2.0);
        float y = boundingRect.y + (boundingRect.height / 2.0);
        float euclideanDistance = cv::pow((double)(cv::pow((yCenter - y), 2) - cv::pow((xCenter - x), 2)), 0.5);
        if (euclideanDistance < currentDistance) {
            currentDistance = euclideanDistance;
            centerCountour = *it;
        }
    }
        
    Contour* contourClass = [[Contour alloc] init];
    [contourClass setContour: centerCountour];
    [contourClass setFilledImage:filledImage];
    [contourClass calculateProperties];
    
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass area]] forKey:@"area"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass convexArea]] forKey:@"convexArea"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass eccentricity]] forKey:@"eccentricity"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass equivDiameter]] forKey:@"equivDiameter"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass extent]] forKey:@"extent"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass filledArea]] forKey:@"filledArea"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass minorAxisLength]] forKey:@"minorAxisLength"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass majorAxisLength]] forKey:@"majorAxisLength"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass maxIntensity]] forKey:@"maxIntensity"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass minIntensity]] forKey:@"minIntensity"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass meanIntensity]] forKey:@"meanIntensity"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass perimeter]] forKey:@"perimeter"];
    [regionProperties setValue:[NSNumber numberWithFloat:[contourClass solidity]] forKey:@"solidity"];
    
    
    // WAYNE NOTE: This shold only return region properties for the contour closest to the image center
    // Use bounding boxes and calculate euclidean distance to center?
    return regionProperties;
}



@end
