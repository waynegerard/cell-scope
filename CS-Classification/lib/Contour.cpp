#include "Contour.h"
#include <opencv2/imgproc/imgproc.hpp>

Contour::Contour (ContourType c, cv::Mat filledImg) {
    area = new float;
    convexArea = new float;
    solidity = new float;
    equivDiameter = new float;
    extent = new float;
    perimeter = new float;
    minIntensity = new float;
    maxIntensity = new float;
    meanIntensity = new float;
    filledArea = new float;
    minorAxisLength = new float;
    majorAxisLength = new float;
    eccentricity = new float;
    contour = new ContourType;
    
    *contour = c;
    filledImage = &filledImg;

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
    delete filledImage;
}


void Contour::calculateAreaProperties()
{
    *area = (float)cv::contourArea(*contour);
    
    cv::Mat hull;
    cv::convexHull(*contour, hull);
    *convexArea = (float)contourArea(hull);
    *solidity = *area / *convexArea;
    
    *equivDiameter = (float)pow((4.0 * M_PI * (*area)), 0.5);
}

void Contour::calculateMiscProperties()
{
    cv::Rect r = cv::boundingRect(*contour);
    *extent = *area / (r.width * r.height);
    
    *perimeter = (float)cv::arcLength(*contour, true);
}

void Contour::calculateAxisProperties()
{
    if (contour->size() < 5)
    {
        *minorAxisLength = 0;
        *majorAxisLength = 0;
        *eccentricity = 0;
        return;
    }
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
    *eccentricity = (float)pow(tmp, 0.5);
    
}

void Contour::calculateMaskedImageProperties(cv::Mat image)
{
    double minVal;
    double maxVal;
    
    cv::minMaxLoc(image, &minVal, &maxVal, NULL, NULL, *filledImage);
    *minIntensity = (float)minVal;
    *maxIntensity = (float)maxVal;
    *meanIntensity = (float)cv::mean(image, *filledImage)[0];
    
    *filledArea = countNonZero(*filledImage);
}

void Contour::calculateProperties(cv::Mat image)
{
    calculateAreaProperties();
    calculateAxisProperties();
    calculateMaskedImageProperties(image);
    calculateMiscProperties();
}


float Contour::getArea()
{
    return *area;
}

float Contour::getConvexArea()
{
    return *convexArea;
}

float Contour::getEccentricity()
{
    return *eccentricity;
}

float Contour::getEquivDiameter()
{
    return *equivDiameter;
}

float Contour::getExtent()
{
    return *extent;
}

float Contour::getFilledArea()
{
    return *filledArea;
}

float Contour::getMajorAxisLength()
{
    return *majorAxisLength;
}

float Contour::getMinorAxisLength()
{
    return *minorAxisLength;
}

float Contour::getMaxIntensity()
{
    return *maxIntensity;
}

float Contour::getMinIntensity()
{
    return *minIntensity;
}

float Contour::getMeanIntensity()
{
    return *meanIntensity;
}

float Contour::getPerimeter()
{
    return *perimeter;
}

float Contour::getSolidity()
{
    return *solidity;
}

