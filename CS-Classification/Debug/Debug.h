#include "Globals.h"
#include <string>

#if __APPLE__
    #define OUTPUT_FOLDER "/Users/wgerard/Dropbox/CS_Comparisons/cpp/"
#else // Assumed to be windows
    #define OUTPUT_FOLDER "C:\\Users\\Wayne\\Dropbox\\CS_Comparisons\\cpp\\"
#endif

using namespace cv;
using namespace std;

namespace Debug
{
    void print(Mat mat, const char* name);

    void printStats(Mat mat, const char* fileName);
}