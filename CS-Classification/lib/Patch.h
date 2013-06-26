#ifndef PATCH_H
#define PATCH_H

#include "Globals.h"

class Patch {
    int *row, 
		*col;
	cv::Mat* origPatch;
    cv::Mat* geom;
    cv::Mat* phi;
    cv::Mat* binPatch;

    public:
        Patch (int,int,cv::Mat);
        ~Patch ();
        void calculateBinarizedPatch();
        cv::Mat getPatch();
        cv::Mat* getBinPatch();
        void setPhi(const cv::Mat);
        void setGeom(const cv::Mat);
        void setBinPatch(const cv::Mat);

};

#endif