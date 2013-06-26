#include "Patch.h"

Patch::Patch (int a, int b, cv::Mat c) {
    row = new int;
    col = new int;
    origPatch = new cv::Mat(c);
    
    geom = new cv::Mat;
    phi = new cv::Mat;
    binPatch = new cv::Mat;
    
    *row = a;
    *col = b;
    
}

Patch::~Patch () {
    delete row;
    delete col;

}


void Patch::calculateBinarizedPatch()
{
    // Calculate binarized patch using Otsu threshold.
    
    cv::threshold(*origPatch,*binPatch,0,255,CV_THRESH_BINARY|CV_THRESH_OTSU);
}

cv::Mat Patch::getPatch()
{
    return *origPatch;
}

void Patch::setPhi(const cv::Mat p)
{
    *phi = p;
}

void Patch::setGeom(const cv::Mat g)
{
    *geom = g;
}

cv::Mat* Patch::getBinPatch()
{
    return binPatch;
}

void Patch::setBinPatch(const cv::Mat b)
{
    *binPatch = b;
}