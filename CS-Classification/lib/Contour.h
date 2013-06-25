#ifndef PATCH_H
#define PATCH_H

#include "Globals.h"

class Contour {
    ContourType* contour;
    cv::Mat* image, *filledImage;
    float *area, *convexArea, *eccentricity, *equivDiameter, *extent, *filledArea, *majorAxisLength;
    float *minorAxisLength, *maxIntensity, *minIntensity, *meanIntensity, *perimeter, *solidity;
	
private:
    void calculateAreaProperties();
    void calculateAxisProperties();
    void calculateMaskedImageProperties();
    void calculateMiscProperties();

public:
    Contour (ContourType, cv::Mat);
    void calculateProperties();
    float getArea();
    float getConvexArea();
    float getEccentricity();
    float getEquivDiameter();
    float getExtent();
    float getFilledArea();
    float getMajorAxisLength();
    float getMinorAxisLength();
    float getMaxIntensity();
    float getMinIntensity();
    float getMeanIntensity();
    float getPerimeter();
    float getSolidity();
    ~Contour ();
};

#endif
