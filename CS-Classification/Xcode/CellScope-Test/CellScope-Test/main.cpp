//
//  main.cpp
//  CellScope-Test
//
//  Created by Wayne Gerard on 6/12/13.
//  Copyright (c) 2013 Wayne Gerard. All rights reserved.
//

#include <iostream>
#include <string>
#include "Classifier.h"


using namespace cv;
using namespace std;

int main(int argc, const char * argv[])
{
    Mat image;
    string image_path = "/Users/wgerard/Dev/cell-scope/CS-Classification/Xcode/CellScope-Test/1350_Clay_Fluor_Yes.png";
    image = imread(image_path, CV_LOAD_IMAGE_GRAYSCALE);
    cout << "Starting\n";
    Classifier::runWithImage(image);
    cout << "Finished\n";
    return 0;
}

