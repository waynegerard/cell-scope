#ifndef CLASSIFIER_H
#define CLASSIFIER_H

#include "Globals.h"
#include "svm.h"

namespace Classifier 
{

	/**
		Initializes an image by both pulling out a single channel and normalizing,
		if necessary
		@param image The image to normalize/pull channel from
		@return      Returns the image as a normalized image, with one channel
	*/
	cv::Mat initializeImage(cv::Mat image);

	/**
		Identifies objects in a given matrix
		@param image The image to identify objects in
		@return      Returns a binarized version of the image, for identification
	*/
	cv::Mat objectIdentification(cv::Mat image);

	/**
		Performs feature detection given a binary image
		@param imageBw  The binarized image
		@param original The original image
		@return         Returns a vector of features found in the image
	*/
    std::vector<MatDict > featureDetection(cv::Mat imageBw, cv::Mat original);

	/**
	  Loads a CSV file into an openCV matrix
	  @param file_path The file path to load the CSV from
	  @return          Returns the loaded CSV as an openCV matrix
	*/
    cv::Mat loadCSV(const char* file_path);

	/**
		A recreation of the repMat function from matlab. Repeats the given matrix |matrix| 
		|multiplier| times.
		@param matrix     The matrix to be repeated
		@param multiplier The number of times to repeat the matrix
		@return           Returns the repeated matrix.
	*/
    cv::Mat repMat(cv::Mat matrix, int multiplier);

	/**
	  Classifies the objects, and returns a vector of probabilities
	  @param features   The vector of features to be classified
	  @param model_path The string path to the model file
	  @param max_path   The string path to the train_max file (assumed to be a CSV)
	  @param min_path   The string path to the train_min file (assumed to be a CSV)
	  @return           Returns the vector of probabilities, one for each feature
	*/
    std::vector<double> classifyObjects(std::vector<MatDict > features, const char* model_path, const char* max_path, const char* min_path);

	/**
		Runs the matrix. Calculates scores and centroids that pass the low-confidence filter.
		@param img The image to run
	*/
	cv::Mat runWithImage(const cv::Mat image, const char* model_path, const char* min_path, const char* max_path);
    
    /**
        Filters out probability results that are too close, or not significant enough
        @param prob_results    The probability results from classifyObjects
        @param features        Features found from feature detection
        @param normalizedImage The normalized image
        @return                Returns scores and centers from significant results
     */
    cv::Mat filterProbabilities(std::vector<double> prob_results, std::vector<MatDict > features, cv::Mat normalizedImage);

}
#endif