#include "Patch.h"

Patch::Patch (int a, int b, cv::Mat c) {
    row = new int;
    col = new int;
    patch = new cv::Mat(c);
    geom = new cv::Mat;
    phi = new cv::Mat;
    binPatch = new cv::Mat;
    
    *row = a;
    *col = b;
    
}

Patch::~Patch () {
    delete row;
    delete col;
    delete patch;
    delete geom;
    delete phi;
    delete binPatch;
}


void Patch::calculateBinarizedPatch()
{
    // Calculate binarized patch using Otsu threshold.
    
    // move zeros to the back of a temp array
    cv::Mat copyImg = *patch;
    uchar* ptr = copyImg.datastart;
    uchar* ptr_end = copyImg.dataend;
    while (ptr < ptr_end) {
        if (*ptr == 0) { // swap if zero
            uchar tmp = *ptr_end;
            *ptr_end = *ptr;
            *ptr = tmp;
            ptr_end--; // make array smaller
        } else {
            ptr++;
        }
    }
    
    // make a new matrix with only valid data
    cv::Mat nz = cv::Mat(std::vector<uchar>(copyImg.datastart,ptr_end),true);
    
    // compute optimal Otsu threshold
    double thresh = cv::threshold(nz,nz,0,255,CV_THRESH_BINARY | CV_THRESH_OTSU);
    
    // apply threshold
    cv::threshold(*patch,*binPatch,thresh,255,CV_THRESH_BINARY_INV);
}

cv::Mat* Patch::getPatch()
{
    return patch;
}

void Patch::setPhi(cv::Mat p)
{
    phi = &p;
}

void Patch::setGeom(cv::Mat g)
{
    geom = &g;
}

cv::Mat* Patch::getBinPatch()
{
    return binPatch;
}

void Patch::setBinPatch(cv::Mat b)
{
    binPatch = &b;
}