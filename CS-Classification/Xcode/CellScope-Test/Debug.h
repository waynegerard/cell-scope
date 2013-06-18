#include "Globals.h"
#include <string>

using namespace cv;
using namespace std;

namespace Debug
{
    void print(Mat mat, int rows, int cols, char* name);

    void printStats(Mat mat, char* fileName);
}