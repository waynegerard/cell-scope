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
    float xCenter = (float)img.cols / 2.0f;
    float yCenter = (float)img.rows / 2.0f;
    unsigned long currentDistance = 1E10;
    ContourType centerContour;
    for (; it != contours.end(); ++it) {
        cv::Rect boundingRect = cv::boundingRect(*it);
        float x = boundingRect.x + (boundingRect.width / 2.0f);
        float y = boundingRect.y + (boundingRect.height / 2.0f);
        
        double yDistance = cv::pow((yCenter - y), 2);
        double xDistance = cv::pow((xCenter - x), 2);
        double diff = (yDistance - xDistance);
        if (diff < 0) {
            diff = -diff;
        }
        double euclideanDistance = cv::pow(diff, 0.5);
        if (euclideanDistance < currentDistance) {
            currentDistance = euclideanDistance;
            centerContour = *it;
        }
    }
        
    Contour* contourClass = new Contour(centerContour, filledImage);
    contourClass->calculateProperties(img);

    regionProperties.insert(std::pair<const char*, float>("eulerNumber", eulerNumber));
    regionProperties.insert(std::pair<const char*, float>("area", contourClass->getArea()));
    regionProperties.insert(std::pair<const char*, float>("convexArea", contourClass->getConvexArea()));
    regionProperties.insert(std::pair<const char*, float>("eccentricity", contourClass->getEccentricity()));
    regionProperties.insert(std::pair<const char*, float>("equivDiameter", contourClass->getEquivDiameter()));
    regionProperties.insert(std::pair<const char*, float>("extent", contourClass->getExtent()));
    regionProperties.insert(std::pair<const char*, float>("filledArea", contourClass->getFilledArea()));
    regionProperties.insert(std::pair<const char*, float>("minorAxisLength", contourClass->getMinorAxisLength()));
    regionProperties.insert(std::pair<const char*, float>("majorAxisLength", contourClass->getMajorAxisLength()));
    regionProperties.insert(std::pair<const char*, float>("maxIntensity", contourClass->getMaxIntensity()));
    regionProperties.insert(std::pair<const char*, float>("minIntensity", contourClass->getMinIntensity()));
    regionProperties.insert(std::pair<const char*, float>("meanIntensity", contourClass->getMeanIntensity()));
    regionProperties.insert(std::pair<const char*, float>("perimeter", contourClass->getPerimeter()));
    regionProperties.insert(std::pair<const char*, float>("solidity", contourClass->getSolidity()));
        
    return regionProperties;
}
}
