#include "Patch.h"
#include "MatrixOperations.h"

Patch::Patch (int a, int b, cv::Mat c) {
    row = new int;
    col = new int;
    origPatch = new cv::Mat(c.clone());
    
    binPatch = new cv::Mat;
    geom = new cv::Mat;
    phi = new cv::Mat;
    
    *row = a;
    *col = b;
    
}

Patch::~Patch () {
    delete row;
    delete col;
    delete binPatch;
    delete geom;
    delete phi;
    delete origPatch;

}


int Patch::getRow()
{
    return *row;
}

int Patch::getCol()
{
    return *col;
}

cv::Mat Patch::getGeom()
{
    return *geom;
}

cv::Mat Patch::getPhi()
{
    return *phi;
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