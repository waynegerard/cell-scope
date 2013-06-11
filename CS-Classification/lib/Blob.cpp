#include "Blob.h"
#include "MatrixOperations.h"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"

namespace Blob 
{
	cv::Mat crossCorrelateWithGaussian(cv::Mat matrix) 
	{
		cv::Mat correlationMatrix;
		cv::Mat binarizedMatrix;
		cv::Mat result;

		int kernelSize = 17;               // Size of Gaussian kernel // 16 + 1
		float kernelStdDev  = 1.5;         // StdDev of Gaussian kernel
		double correlationThreshold = 0.122;  // Threshold on normalized cross-correlation

		cv::GaussianBlur(matrix, correlationMatrix, cv::Size(kernelSize, kernelSize), kernelStdDev, kernelStdDev); 
		cv::threshold(correlationMatrix, binarizedMatrix, correlationThreshold, 1.0, CV_THRESH_BINARY);
    
		// Touch-up morphological operations
		int type = cv::MORPH_RECT;
		cv::Mat element = getStructuringElement(type, cv::Size(3,3));
		cv::dilate(binarizedMatrix, result, element);
    
		return result;
	}

	cv::Mat blobIdentification(cv::Mat image) 
	{
    
		cv::Mat thresholdCutoff = cv::Mat(1,1, CV_32F);
		cv::Mat grayscaleImage;
		cv::Mat imageOpening;
		cv::Mat imageDifference;
		cv::Mat imageThreshold;
		cv::Mat meanImageDifference;
		cv::Mat stdDevImageDifference;
    
		// Morphological opening
		cv::Mat element = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(10,10));
		imageOpening = cv::Mat(image.rows, image.cols, image.type());
		cv::morphologyEx(image, imageOpening, cv::MORPH_OPEN, element);
    
		// Get the threshold cutoff, generate the image difference
		cv::subtract(image, imageOpening, imageDifference);
		cv::meanStdDev(imageDifference, meanImageDifference, stdDevImageDifference);
		cv::add(meanImageDifference, stdDevImageDifference, thresholdCutoff);
		cv::add(thresholdCutoff, stdDevImageDifference, thresholdCutoff);
		cv::add(thresholdCutoff, stdDevImageDifference, thresholdCutoff);

		// Use the threshold
		imageThreshold = MatrixOperations::greaterThanValue(thresholdCutoff.at<float>(0,0), imageDifference);
    
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