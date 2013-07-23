#include "BlobClass.h"
#include "MatrixOperations.h"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"

namespace BlobClass
{
	cv::Mat crossCorrelateWithGaussian(cv::Mat matrix) 
	{
		cv::Mat correlationMatrix;
		cv::Mat binarizedMatrix;
		cv::Mat result;

		int kernelSize = 17;               // Size of Gaussian kernel // 16 + 1
		float kernelStdDev  = 1.5f;         // StdDev of Gaussian kernel
		double correlationThreshold = 0.125;//0.130;  // Threshold on normalized cross-correlation

		cv::GaussianBlur(matrix, correlationMatrix, cv::Size(kernelSize, kernelSize), kernelStdDev, kernelStdDev); 
		cv::threshold(correlationMatrix, binarizedMatrix, correlationThreshold, 1.0, CV_THRESH_BINARY);
    
		// Touch-up morphological operations
		int type = cv::MORPH_RECT;
		cv::Mat element = getStructuringElement(type, cv::Size(2,2));
		cv::morphologyEx(binarizedMatrix, result, cv::MORPH_CLOSE, element);
		
		return result;
	}

	cv::Mat blobIdentification(cv::Mat image) 
	{
		cv::Mat grayscaleImage;
		cv::Mat imageOpening;
		cv::Mat imageDifference;
		cv::Mat imageThreshold;
		cv::Mat meanImageDifference;
		cv::Mat stdDevImageDifference;
    
		// Morphological opening
		
		cv::morphologyEx(image, imageOpening, cv::MORPH_OPEN, cv::getStructuringElement(cv::MORPH_RECT, cv::Size(9,9)));
		
		// Get the threshold cutoff, generate the image difference
		cv::subtract(image, imageOpening, imageDifference);
        
		cv::meanStdDev(imageDifference, meanImageDifference, stdDevImageDifference);
		double mean = meanImageDifference.at<double>(0, 0);
		double stdev = stdDevImageDifference.at<double>(0, 0);
		double threshold_value = mean + (3 * stdev);
		imageThreshold = MatrixOperations::greaterThanValue((float)threshold_value, imageDifference);
        
		// Only use pixels which pass the threshold from the cross correlation
		cv::Mat grayscaleCrossCorrelation = crossCorrelateWithGaussian(image);
		cv::bitwise_and(imageThreshold, grayscaleCrossCorrelation, grayscaleImage);

		// Morphological close
		cv::Mat closingElement = getStructuringElement(cv::MORPH_RECT, cv::Size(3,3));
		cv::morphologyEx(grayscaleImage, grayscaleImage, cv::MORPH_CLOSE, closingElement);
    
		grayscaleImage.convertTo(grayscaleImage, CV_8UC1);
    
		return grayscaleImage;
	}
}