//
//  Region.h
//  CellScope
//
//  Created by Wayne Gerard on 2/25/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

/**
    Represents a region similar to ones found in Matlab. Mostly meant to recreate the functionality
    of the regionprops method from Matlab.
 
    Collaborates the following properties from the contours:
 
    1) Area
    2) ConvexArea
    3) Eccentricity
    4) EquivDiameter
    5) Extent
    6) FilledArea
    7) MajorAxisLength
    8) MinorAxisLength
    9) MaxIntensity
    10) MinIntensity
    11) MeanIntensity
    12) Perimeter
    13) Solidity
    14) EulerNumber
 
 */
@interface Region : NSObject {
    ContourContainerType _contours;
    cv::Mat          _img;
}

/**
    Gets the region properties for the given contours |contours| contained within the image |img|
    @param contours The vector of points for each contour
    @param img      The image to look within
    @return         Returns a dictionary of region properties, calculated using matlab.
 */
+ (NSDictionary*) getRegionPropertiesWithContours:(ContourContainerType) contours withImage:(cv::Mat) img;


@property (nonatomic, assign) ContourContainerType contours;
@property (nonatomic, assign) cv::Mat img;

@end
