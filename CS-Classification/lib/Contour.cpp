#include "Contour.h"
#include <opencv2/imgproc/imgproc.hpp>

Contour::Contour (ContourType contour, int b, cv::Mat c) {
    *area = new double;
    *convexArea = new double;
    *solidity = new double;
    *equivDiameter = new double;
    *extent = new double;
    *perimeter = new double;ß
    *minIntensity = new double;
    *maxIntensity = new double;
    *meanIntensity = new double;
    *filledArea = new cv::Mat();
    *contour = contour;
    *minorAxisLength = new double;
    *majorAxisLength = new double;
    *eccentricity = new double;

    *contour = contour;
    

}

Contour::~Contour () {
    delete area;
    delete convexArea;
    delete solidity;
    delete equivDiameter;
    delete extent;
    delete perimeter;
    delete minIntensity;
    delete maxIntensity;
    delete meanIntensity;
    delete filledArea;
    delete contour;
    delete minorAxisLength;
    delete majorAxisLength;
    delete eccentricity;
}


void Contour::calculateAreaProperties()
{
    *area = cv::contourArea(*contour);
    
    cv::Mat hull;
    cv::convexHull(*contour, hull);
    *convexArea = contourArea(hull);
    *solidity = *area / *convexArea;
    
    *equivDiameter = pow((4.0 * M_PI * (*area)), 0.5);
}

void Contour::calculateMiscProperties()
{
    cv::Rect r = cv::boundingRect(*contour);
    *extent = *area / (r.width * r.height);
    
    *perimeter = cv::arcLength(*contour, true);
}

void Contour::calculateAxisProperties()
{
    cv::RotatedRect ellipse = cv::fitEllipse(*contour);
    
    cv::Size2f sz = ellipse.size;
    if (sz.width <= sz.height) {
        *minorAxisLength = sz.width;
        *majorAxisLength = sz.height;
    } else {
        *minorAxisLength = sz.height;
        *majorAxisLength = sz.width;
    }
    
    double tmp = *minorAxisLength / *majorAxisLength;
    tmp = pow(tmp, 2);
    tmp = 1 - tmp;
    *eccentricity = pow(tmp, 0.5);
    
}

void Contour::calculateMaskedImageProperties()
{
    double minVal;
    double maxVal;
    
    cv::minMaxLoc(*image, &minVal, &maxVal, NULL, NULL, *filledImage);
    *minIntensity = minVal;
    *maxIntensity = maxVal;
    *meanIntensity = cv::mean(*image, *filledImage)[0];
    
    *filledArea = countNonZero(*filledImage);
}

void Contour::calculateProperties()
{
    calculateAreaProperties();
    calculateAxisProperties();
    calculateMaskedImageProperties();
    calculateMiscProperties();
}


float getArea()
{
    return *area;
}

float getConvexArea()
{
    return *convexArea;
}

float getEccentricity()
{
    return *eccentricity;
}

float getEquivDiameter()
{
    return *equivDiameter;
}

float getExtent()
{
    return *extent;
}

float getFilledArea()
{
    return *filledArea;
}

float getMajorAxisLength()
{
    return *majorAxisLength;
}

float getMinorAxisLength()
{
    return *minorAxisLength;
}

float getMaxIntensity()
{
    return *maxIntensity;
}

float getMinIntensity()
{
    return *minIntensity;
}

float getMeanIntensity()
{
    return *meanIntensity;
}

float getPerimeter()
{
    return *perimeter;
}

float getSolidity()
{
    return *solidity;
}



@end
