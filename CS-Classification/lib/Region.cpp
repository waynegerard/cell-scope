#include "Region.h"
#include "Contour.h"
#include <opencv2/imgproc/imgproc.hpp>
using namespace cv;


namespace Region
{
std::map<const char*, float> getProperties(ContourContainerType contours, Mat img)
{
    std::map<const char*, float> regionProperties;
    
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
        
    Contour* contourClass = new Contour(centerCountour, filledImage);
    contourClass->calculateProperties();

    regionProperties.set("eulerNumber", eulerNumber);
    regionProperties.set("area", contourClass->getArea());
    regionProperties.set("convexArea", contourClass->getConvexArea());
    regionProperties.set("eccentricity", contourClass->getEccentricity());
    regionProperties.set("equivDiameter", contourClass->getEquivDiameter());
    regionProperties.set("extent", contourClass->getExtent());
    regionProperties.set("filledArea", contourClass->getFilledArea());
    regionProperties.set("minorAxisLength", contourClass->getMinorAxisLength());
    regionProperties.set("majorAxisLength", contourClass->getMajorAxisLength());
    regionProperties.set("maxIntensity", contourClass->getMaxIntensity());
    regionProperties.set("minIntensity", contourClass->getMinIntensity());
    regionProperties.set("meanIntensity", contourClass->getMeanIntensity());
    regionProperties.set("perimeter", contourClass->getPerimeter());
    regionProperties.set("solidity", contourClass->getSolidity());
        
    return regionProperties;
}
}
