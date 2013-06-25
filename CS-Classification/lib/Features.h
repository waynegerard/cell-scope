#include "Globals.h"
#include "Patch.h"

using namespace cv;

namespace Features
{
    void calculateFeatures(vector<Patch*> blobs);
	bool checkPartialPatch(int row, int col, int maxRow, int maxCol);
	Mat geometricFeatures(Mat* binPatch);
	Patch* makePatch(int row, int col, Mat original);

}