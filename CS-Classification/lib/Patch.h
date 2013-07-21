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
        cv::Mat calculateBinarizedPatch();
        int getRow();
        int getCol();
        cv::Mat getGeom();
        cv::Mat getPhi();
        cv::Mat getPatch();
        cv::Mat* getBinPatch();
        void setPhi(const cv::Mat);
        void setGeom(const cv::Mat);
        void setBinPatch(const cv::Mat);

};

#endif