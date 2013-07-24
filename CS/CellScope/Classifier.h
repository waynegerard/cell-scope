#ifndef CLASSIFIER_H
#define CLASSIFIER_H

#include "ClassifierGlobals.h"
#include "Globals.h"
#include "svm.h"

namespace Classifier 
{
	/**
		Runs the matrix. Calculates scores and centroids that pass the low-confidence filter.
		@param img The image to run
	*/
	cv::Mat runWithImage(const cv::Mat image);
}
#endif