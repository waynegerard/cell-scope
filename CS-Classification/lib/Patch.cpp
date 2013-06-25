#include "Patch.h"

Patch::Patch (int a, int b, cv::Mat c) {
    row = new int;
    col = new int;
    patch = new cv::Mat;
    geom = new cv::Mat;
    phi = new cv::Mat;
    binPatch = new cv::Mat;
    
    *row = a;
    *col = b;
    *patch = c;
}

Patch::~Patch () {
    delete row;
    delete col;
    delete patch;
    delete geom;
    delete phi;
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

void Patch::setBinPatch(cv::Mat b)
{
    binPatch = &b;
}