#ifndef PATCH_H
#define PATCH_H

#include "Globals.h"

class Patch {
    int *row, 
		*col;
	cv::Mat *patch;
	
  public:
    Patch (int,int,cv::Mat);
    ~Patch ();
};

#endif