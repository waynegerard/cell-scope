//
//  Contour.mm
//  CellScope
//
//  Created by Wayne Gerard on 3/5/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Contour.h"
#import <opencv2/imgproc/imgproc.hpp>

@implementation Contour

@synthesize contour = _contour, image = _image, filledImage = _filledImage;
@synthesize area = _area, convexArea = _convexArea, eccentricity = _eccentricity, equivDiameter = _equivDiameter;
@synthesize extent = _extent, filledArea = _filledArea, majorAxisLength = _majorAxisLength;
@synthesize minorAxisLength = _minorAxisLength, maxIntensity = _maxIntensity, minIntensity = _minIntensity;
@synthesize meanIntensity = _meanIntensity, perimeter = _perimeter, solidity = _solidity;

- (void) calculateProperties {
    [self calculateAreaProperties];
    [self calculateAxisProperties];
    [self calculateMaskedImageProperties];
    [self calculateMiscProperties];
}

- (void) calculateAreaProperties {
    self.area = cv::contourArea(self.contour);

    Mat hull;
    cv::convexHull(self.contour, hull);
    self.convexArea = contourArea(hull);
    self.solidity = self.area / self.convexArea;

    self.equivDiameter = pow((4.0 * M_PI * self.area), 0.5);
}

- (void) calculateMiscProperties {
    cv::Rect r = cv::boundingRect(self.contour);
    self.extent = self.area / (r.width * r.height);
    
    self.perimeter = cv::arcLength(self.contour, true);
}

- (void) calculateAxisProperties {
    RotatedRect ellipse = cv::fitEllipse(self.contour);
    
    Size2f sz = ellipse.size;
    if (sz.width <= sz.height) {
        self.minorAxisLength = sz.width;
        self.majorAxisLength = sz.height;
    } else {
        self.minorAxisLength = sz.height;
        self.majorAxisLength = sz.width;
    }
    
    double tmp = self.minorAxisLength / self.majorAxisLength;
    tmp = pow(tmp, 2);
    tmp = 1 - tmp;
    self.eccentricity = pow(tmp, 0.5);

}

- (void) calculateMaskedImageProperties {
    double* minVal;
    double* maxVal;
    
    minMaxLoc(self.image, minVal, maxVal, NULL, NULL, self.filledImage);
    self.minIntensity = *minVal;
    self.maxIntensity = *maxVal;
    self.meanIntensity = cv::mean(self.image, self.filledImage)[0];
    
    self.filledArea = countNonZero(self.filledImage);
}

@end
