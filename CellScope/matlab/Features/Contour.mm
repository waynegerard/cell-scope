//
//  Contour.mm
//  CellScope
//
//  Created by Wayne Gerard on 3/5/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Contour.h"
using namespace cv;

@implementation Contour

@synthesize contour = _contour;
@synthesize area = _area, convexArea = _convexArea, eccentricity = _eccentricity, equivDiameter = _equivDiameter;
@synthesize extent = _extent, filledArea = _filledArea, majorAxisLength = _majorAxisLength;
@synthesize minorAxisLength = _minorAxisLength, maxIntensity = _maxIntensity, minIntensity = _minIntensity;
@synthesize meanIntensity = _meanIntensity, perimeter = _perimeter, solidity = _solidity, eulerNumber = _eulerNumber;


- (double) calculateArea {
    if (self.area) {
        return self.area;
    }
    self.area = cv::contourArea(self.contour);
    return self.area;
}

- (double) calculateConvexArea {
    
    Mat hull;
        cv::convexHull(self.contours[i], hull);
        double convexArea = cv::contourArea(hull);
        convexAreas.at<double>(0, i) = convexArea;
    }
    return convexAreas;
}

- (double) calculateEccentricity {
    Mat eccentricities(1, self.contours.size(), CV_8UC3);
    //   # eccentricity = sqrt( 1 - (ma/MA)^2) --- ma= minor axis --- MA= major axis
    //self.eccentricity = np.sqrt(1-(self.minoraxis_length/self.majoraxis_length)**2)
    return eccentricities;
}

- (double) calculateEquivDiameter {
    Mat diameters(1, self.contours.size(), CV_8UC3);
    for (int i = 0; i < self.contours.size(); i++) {
        // self.equi_diameter = np.sqrt(4*self.area/np.pi)
        np.sqrt(4*self.area/np.pi)
    }
    return diameters;
}

- (double) calculateExtent {
    Mat extents(1, self.contours.size(), CV_8UC3);
    //# extent = contour area/boundingrect area
    //self.extent = self.area/(self.bw*self.bh)
    return extents;
}

- (double) calculateFilledArea {
    Mat filledAreas(1, self.contours.size(), CV_8UC3);
    //# filled image :- binary image with contour region white and others black
    //self.filledImage = np.zeros(self.img.shape[0:2],np.uint8)
    //cv2.drawContours(self.filledImage,[self.cnt],0,255,-1)
    
    //# area of filled image
    //filledArea = cv2.countNonZero(self.filledImage)
    
    return filledAreas;
}

- (double) calculateMajorAxisLength {
    Mat axisLengths(1, self.contours.size(), CV_8UC3);
    // self.ellipse = cv2.fitEllipse(cnt)
    
    //# center, axis_length and orientation of ellipse
    //(self.center,self.axes,self.orientation) = self.ellipse
    
    //# length of MAJOR and minor axis
    //self.majoraxis_length = max(self.axes)
    //self.minoraxis_length = min(self.axes)
    
    return axisLengths;
}

- (double) calculateMinorAxisLength {
    Mat axisLengths(1, self.contours.size(), CV_8UC3);
    return axisLengths;
}

- (double) calculateMaxIntensity {
    Mat maxIntensities(1, self.contours.size(), CV_8UC3);
    return maxIntensities;
}

- (double) calculateMinIntensity {
    Mat minIntensities(1, self.contours.size(), CV_8UC3);
    return minIntensities;
}

- (double) calculateMeanIntensity {
    //# mean value, minvalue, maxvalue
    //self.minval,self.maxval,self.minloc,self.maxloc = cv2.minMaxLoc(self.img,mask = self.filledImage)
    //self.meanval = cv2.mean(self.img,mask = self.filledImage)
    Mat meanIntensities(1, self.contours.size(), CV_8UC3);
    return meanIntensities;
}

- (double) calculatePerimeter {
    if (self.perimeter) {
        return self.perimeter;
    }
    self.perimeter = cv::arcLength(self.contour, true);
    return self.perimeter;
}

- (double) calculateSolidity {
    //# solidity = contour area / convex hull area
    //self.solidity = self.area/float(self.convex_area)
    NSLog(@"Stub");
}

- (double) calculateEulerNumber {
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
