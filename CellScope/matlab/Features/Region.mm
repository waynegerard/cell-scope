//
//  Region.m
//  CellScope
//
//  Created by Wayne Gerard on 2/25/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Region.h"
#import <opencv2/imgproc/imgproc.hpp>
using namespace cv;


@implementation Region
@synthesize contours = _contours, img = _img;


+ (NSDictionary*) getRegionPropertiesWithContours:(contourContainer) contours withImage:(cv::Mat) img {
    NSDictionary* regionProperties = [NSDictionary dictionary];
    Region* region = [[Region alloc] init];
    return regionProperties;
}

- (Mat) calculateArea {
    Mat areas(1, self.contours.size(), CV_8UC3);
    for (int i = 0; i < self.contours.size(); i++) {
        double area = cv::contourArea(self.contours[i]);
        areas.at<double>(0, i) = area;
    }
    return areas;
}

- (Mat) calculateConvexArea {
    Mat convexAreas(1, self.contours.size(), CV_8UC3);
    //# convex hull
    //self.convex_hull = cv2.convexHull(cnt)
    
    //# convex hull area
    //self.convex_area = cv2.contourArea(self.convex_hull)
    return convexAreas;
}

- (Mat) calculateEccentricity {
    Mat eccentricities(1, self.contours.size(), CV_8UC3);
    //   # eccentricity = sqrt( 1 - (ma/MA)^2) --- ma= minor axis --- MA= major axis
    //self.eccentricity = np.sqrt(1-(self.minoraxis_length/self.majoraxis_length)**2)
    return eccentricities;
}

- (Mat) calculateEquivDiameter {
    Mat diameters(1, self.contours.size(), CV_8UC3);
    for (int i = 0; i < self.contours.size(); i++) {
        // self.equi_diameter = np.sqrt(4*self.area/np.pi)
        np.sqrt(4*self.area/np.pi)
    }
    return diameters;
}

- (Mat) calculateExtent {
    Mat extents(1, self.contours.size(), CV_8UC3);
    //# extent = contour area/boundingrect area
    //self.extent = self.area/(self.bw*self.bh)
    return extents;
}

- (Mat) calculateFilledArea {
    Mat filledAreas(1, self.contours.size(), CV_8UC3);
    //# filled image :- binary image with contour region white and others black
    //self.filledImage = np.zeros(self.img.shape[0:2],np.uint8)
    //cv2.drawContours(self.filledImage,[self.cnt],0,255,-1)
    
    //# area of filled image
    //filledArea = cv2.countNonZero(self.filledImage)
    
    return filledAreas;
}

- (Mat) calculateMajorAxisLength {
    Mat axisLengths(1, self.contours.size(), CV_8UC3);
    // self.ellipse = cv2.fitEllipse(cnt)
    
    //# center, axis_length and orientation of ellipse
    //(self.center,self.axes,self.orientation) = self.ellipse
    
    //# length of MAJOR and minor axis
    //self.majoraxis_length = max(self.axes)
    //self.minoraxis_length = min(self.axes)

    return axisLengths;
}

- (Mat) calculateMinorAxisLength {
    Mat axisLengths(1, self.contours.size(), CV_8UC3);
    return axisLengths;
}

- (Mat) calculateMaxIntensity {
    Mat maxIntensities(1, self.contours.size(), CV_8UC3);
    return maxIntensities;
}

- (Mat) calculateMinIntensity {   
    Mat minIntensities(1, self.contours.size(), CV_8UC3);
    return minIntensities;
}

- (Mat) calculateMeanIntensity {
    //# mean value, minvalue, maxvalue
    //self.minval,self.maxval,self.minloc,self.maxloc = cv2.minMaxLoc(self.img,mask = self.filledImage)
    //self.meanval = cv2.mean(self.img,mask = self.filledImage)
    Mat meanIntensities(1, self.contours.size(), CV_8UC3);
    return meanIntensities;
}

- (Mat) calculatePerimeter {
    Mat perimeters(1, self.contours.size(), CV_8UC3);
    for (int i = 0; i < self.contours.size(); i++) {
        double area = cv::arcLength(self.contours[i], true);
        perimeters.at<double>(0, i) = area;        
    }
    return perimeters;
}

- (Mat) calculateSolidity {
    //# solidity = contour area / convex hull area
    //self.solidity = self.area/float(self.convex_area)
    NSLog(@"Stub");
}

- (Mat) calculateEulerNumber {
    /*CvSeq *firstContour = NULL;
    CvMemStorage* storage = cvCreateMemStorage(0);
    int holes = 0;
    
    cvFindContours(img, storage, &firstContour, sizeof(CvChain),
                   CV_RETR_CCOMP, CV_CHAIN_CODE);
    
    if(firstContour != NULL)
    {
        CvSeq *aux = firstContour;
        if(aux->v_next)
        {
            holes++;
            aux = aux->v_next;
        }
        
        while(aux->h_next)
        {
            aux = aux->h_next;
            holes++;
        }
    }*/
    NSLog(@"Stub");
}

@end
