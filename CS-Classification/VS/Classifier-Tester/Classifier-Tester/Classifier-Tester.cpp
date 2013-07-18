// Classifier-Tester-Win32.cpp : Defines the entry point for the console application.
//
#include "Classifier.h"
#include "Globals.h"
#include "MatrixOperations.h"

int main(int argc, char *argv[])
{
	char* file = "C:\\Users\\Wayne\\Documents\\GitHub\\cell-scope\\CS-Classification\\Debug\\1350_Clay_Fluor_Yes.png";
	cv::Mat image;
    image = cv::imread(file, CV_LOAD_IMAGE_GRAYSCALE);
	bool result = Classifier::runWithImage(image);

	return 0;
}

