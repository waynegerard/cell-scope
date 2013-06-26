#include "Globals.h"
#include "Patch.h"
#include <string>

#if __APPLE__
    #define OUTPUT_FOLDER "/Users/wgerard/Dropbox/CS_Comparisons/cpp/"
	#define MATLAB_FOLDER "/Users/wgerard/Dropbox/CS_Comparisons/matlab/"
#else // Assumed to be windows
    #define OUTPUT_FOLDER "C:\\Users\\Wayne\\Dropbox\\CS_Comparisons\\cpp\\"
	#define MATLAB_FOLDER "C:\\Users\\Wayne\\Dropbox\\CS_Comparisons\\matlab\\"
#endif

using namespace cv;
using namespace std;

namespace Debug
{
    void print(Mat mat, const char* name);

    void printStats(Mat mat, const char* fileName);

	void printFeatures(vector<Patch*> features, const char* fileName);

	Mat loadMatrix(const char* fileName, int rows, int cols, int type);
}