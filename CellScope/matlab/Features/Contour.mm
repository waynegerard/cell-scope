//
//  Contour.mm
//  CellScope
//
//  Created by Wayne Gerard on 3/5/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Contour.h"
#import <opencv2/imgproc/imgproc.hpp>
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
    self.area = contourArea(self.contour);
    return self.area;
}

- (double) calculateConvexArea {
    if (self.convexArea) {
        return self.convexArea;
    }
    
    Mat hull;
    convexHull(self.contour, hull);
    self.convexArea = contourArea(hull);
    return self.convexArea;
}

- (double) calculateEccentricity {
    //   # eccentricity = sqrt( 1 - (ma/MA)^2) --- ma= minor axis --- MA= major axis
    //self.eccentricity = np.sqrt(1-(self.minoraxis_length/self.majoraxis_length)**2)
}

- (double) calculateEquivDiameter {
    if (self.equivDiameter) {
        return self.equivDiameter;
    }
    double area = [self calculateArea];
    self.equivDiameter = pow((4.0 * M_PI * area), 0.5);
    return self.equivDiameter;
}

- (double) calculateExtent {
    //# extent = contour area/boundingrect area
    //self.extent = self.area/(self.bw*self.bh)
}

- (double) calculateFilledArea {
    //# filled image :- binary image with contour region white and others black
    //self.filledImage = np.zeros(self.img.shape[0:2],np.uint8)
    //cv2.drawContours(self.filledImage,[self.cnt],0,255,-1)
    
    //# area of filled image
    //filledArea = cv2.countNonZero(self.filledImage)
    
}

- (double) calculateMajorAxisLength {
    // self.ellipse = cv2.fitEllipse(cnt)
    
    //# center, axis_length and orientation of ellipse
    //(self.center,self.axes,self.orientation) = self.ellipse
    
    //# length of MAJOR and minor axis
    //self.majoraxis_length = max(self.axes)
    //self.minoraxis_length = min(self.axes)
    
}

- (double) calculateMinorAxisLength {
}

- (double) calculateMaxIntensity {
}

- (double) calculateMinIntensity {
}

- (double) calculateMeanIntensity {
    //# mean value, minvalue, maxvalue
    //self.minval,self.maxval,self.minloc,self.maxloc = cv2.minMaxLoc(self.img,mask = self.filledImage)
    //self.meanval = cv2.mean(self.img,mask = self.filledImage)
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
}

@end
