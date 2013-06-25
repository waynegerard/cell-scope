#include "Patch.h"

Patch::Patch (int a, int b, cv::Mat c) {
  row = new int;
  col = new int;
  patch = new cv::Mat;

  *row = a;
  *col = b;
  *patch = c;
}

Patch::~Patch () {
  delete row;
  delete col;
  delete patch;
}
