#include "Globals.h"

using namespace cv;

namespace Features
{
    void calculateFeatures(vector<MatDict > blobs);
	bool checkPartialPatch(int row, int col, int maxRow, int maxCol);
	Mat geometricFeatures(Mat* binPatch);
	Mat makePatch(int row, int col, Mat original);
    Mat calculateBinarizedPatch(Mat origPatch);
}