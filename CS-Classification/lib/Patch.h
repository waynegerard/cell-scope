#ifndef PATCH_H
#define PATCH_H

#include "Globals.h"

class Patch {
    int *row, 
		*col;
	cv::Mat* patch;
    cv::Mat* geom;
    cv::Mat* phi;
    cv::Mat* binPatch;
	
  public:
    Patch (int,int,cv::Mat);
    cv::Mat* getPatch();
    cv::Mat* getBinPatch();
    void setPhi(cv::Mat);
    void setGeom(cv::Mat);
    void setBinPatch(cv::Mat);
    ~Patch ();
};

#endif