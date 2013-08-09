#ifndef CLASSIFIER_H
#define CLASSIFIER_H

#include "Globals.h"
#include "svm.h"

namespace Classifier 
{
	/**
		Runs the matrix. Calculates scores and centroids that pass the low-confidence filter.
		@param img The image to run
	*/
	cv::Mat runWithImage(const cv::Mat image, const char* model_path, const char* min_path, const char* max_path);
}
#endif