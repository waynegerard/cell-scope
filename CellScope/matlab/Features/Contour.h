//
//  Contour.h
//  CellScope
//
//  Created by Wayne Gerard on 3/5/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"
using namespace cv;

@interface Contour : NSObject {
    /**
        The contour itself, a wrapper around a std::vector<cv::Point>>
     */
    ContourType _contour;
    
    /**
        The image, used for calculation of things like calculating global mins and maxes
     */
    Mat _image;
    
    /**
        The filled image, containing only contours and nothing else
     */
    Mat _filledImage;
    
    /** Geometric features */
    double _area, _convexArea, _eccentricity, _equivDiameter, _extent, _filledArea, _majorAxisLength;
    double _minorAxisLength, _maxIntensity, _minIntensity, _meanIntensity, _perimeter, _solidity;
}

/**
    Runs all calculation methods
 */
- (void) calculateProperties;

/**
    Calculates the area, convexArea, solidity, and equivalent diameter
 */
- (void) calculateAreaProperties;

/**
    Calculates the extent and perimeter
 */
- (void) calculateMiscProperties;

/**
    Calculates the minor axis length, the major axis length, and the eccentricity
 */
- (void) calculateAxisProperties;

/**
    Calculates the min intensity, the max intensity, the mean intensity, and the filled area
 */
- (void) calculateMaskedImageProperties;

@property (nonatomic, assign) ContourType contour;
@property (nonatomic, assign) Mat image;
@property (nonatomic, assign) Mat filledImage;
@property (nonatomic, assign) double area;
@property (nonatomic, assign) double convexArea;
@property (nonatomic, assign) double eccentricity;
@property (nonatomic, assign) double equivDiameter;
@property (nonatomic, assign) double extent;
@property (nonatomic, assign) double filledArea;
@property (nonatomic, assign) double majorAxisLength;
@property (nonatomic, assign) double minorAxisLength;
@property (nonatomic, assign) double maxIntensity;
@property (nonatomic, assign) double minIntensity;
@property (nonatomic, assign) double meanIntensity;
@property (nonatomic, assign) double perimeter;
@property (nonatomic, assign) double solidity;



@end
