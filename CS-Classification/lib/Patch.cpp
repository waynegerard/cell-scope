#include "Patch.h"
#include "MatrixOperations.h"

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
    
    // set center pixel value to be the maximum intensity val
    
    /*
    maxval = patch(round(size(patch,1)/2),round(size(patch,1)/2));
    patch = min(patch,maxval*ones(size(patch)));
    prethresh = patch/maxval;
    
    level = graythresh(prethresh);
    binpatch = im2bw(prethresh,level);
    
    cc = bwconncomp(binpatch);
    */
    
	cv::Mat binpatch;
    ContourContainerType contours;
    std::vector<cv::Point2d> allCenters = MatrixOperations::findWeightedCentroids(contours, binpatch, *origPatch);
    
    /*
    allctrs = regionprops(cc,patch,'WeightedCentroid');
    
    int patchRows = *origPatch.rows;
    
    // Identify object that is closest to the center of the patch
    if(length(allctrs)>1) % if multiple objects
        for m = 1:length(allctrs)
            allctrs(m).dist = dist(allctrs(m).WeightedCentroid, repmat(patchRows/2+0.5,1,2)); %this assumes patch size is even
    end
    [mindist,Igood] = min(vertcat(allctrs(:).dist));
    
    // Erase objects that are not the closest to center
    allI = 1:length(allctrs);
    Ibad = allI(~ismember(allI,Igood));
    binpatch(vertcat(cc.PixelIdxList{Ibad})) = 0;
    */
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