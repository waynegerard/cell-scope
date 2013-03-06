//
//  Contour.h
//  CellScope
//
//  Created by Wayne Gerard on 3/5/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

@interface Contour : NSObject {
    /**
        The contour itself, a wrapper around a cv::vector<cv::Point>>
     */
    Contour* _contour;
    
    /** Geometric features */
    double _area, _convexArea, _eccentricity, _equivDiameter, _extent, _filledArea, _majorAxisLength;
    double _minorAxisLength, _maxIntensity, _minIntensity, _meanIntensity, _perimeter, _solidity, _eulerNumber;
    
}

// Calculation methods
- (double) calculateArea;
- (double) calculateConvexArea;
- (double) calculateEccentricity;
- (double) calculateEquivDiameter;
- (double) calculateExtent;
- (double) calculateFilledArea;
- (double) calculateMajorAxisLength;
- (double) calculateMinorAxisLength;
- (double) calculateMaxIntensity;
- (double) calculateMinIntensity;
- (double) calculateMeanIntensity;
- (double) calculatePerimeter;
- (double) calculateSolidity;
- (double) calculateEulerNumber;

@property (nonatomic, assign) Contour* contour;
@property (nonatomic, assign) double area;
@property (nonatomic, assign) double convexArea;
@property (nonatomic, assign) double eccentricity;
@property (nonatomic, assign) double equivDiameter;
@property (nonatomic, assign) double extent;
@property (nonatomic, assign) double filledarea;
@property (nonatomic, assign) double majorAxisLength;
@property (nonatomic, assign) double minorAxisLength;
@property (nonatomic, assign) double maxIntensity;
@property (nonatomic, assign) double minIntensity;
@property (nonatomic, assign) double meanIntensity;
@property (nonatomic, assign) double perimeter;
@property (nonatomic, assign) double solidity;
@property (nonatomic, assign) double eulerNumber;



@end
