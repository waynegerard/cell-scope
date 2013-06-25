#include "Globals.h"
#include "Patch.h"

using namespace cv;

namespace Features
{
	bool checkPartialPatch(int row, int col, int patchSize, int maxRow, int maxCol);

	Patch* makePatch(int row, int col, int patchSize, Mat original);
}