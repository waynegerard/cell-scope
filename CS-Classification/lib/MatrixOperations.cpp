#include "MatrixOperations.h"
#include "opencv2/highgui/highgui.hpp"

namespace MatrixOperations
{
	cv::Mat greaterThanValue(float compareVal, cv::Mat mat) 
	{
		cv::Mat parsedMatrix = cv::Mat(mat.rows, mat.cols, mat.type());
    
		for (int i = 0; i < mat.rows; i++) {
			for (int j = 0; j < mat.cols; j++) {
				if (mat.type() == CV_32F) {
					float val = mat.at<float>(i, j);
					float newVal = val > compareVal ? (float)1.0 : (float)0.0;
					parsedMatrix.at<float>(i, j) = newVal;
				} else if (mat.type() == CV_64F) {
					double val = mat.at<double>(i, j);
					double newVal = val > compareVal ? 1 : 0;
					parsedMatrix.at<double>(i, j) = newVal;
				} else if (mat.type() == CV_8UC1) {
					int val = (int)mat.at<uchar>(i, j);
					int newVal = val > compareVal ? 1 : 0;
					parsedMatrix.at<int>(i, j) = newVal;
				} 
			}
		}
    
		return parsedMatrix;
	}
    
    std::vector<cv::Point2d> findWeightedCentroids(const ContourContainerType contours, const cv::Mat thresholdImage, const cv::Mat originalImage)
    {
        std::vector<cv::Point2d> pts;

        for (int i = 0; i < contours.size(); i++)
        {
            cv::Mat filledImage = cv::Mat::zeros(thresholdImage.rows, thresholdImage.cols, CV_8UC1);
            cv::Scalar color = cv::Scalar(255, 255, 255);
			cv::drawContours(filledImage, contours, i, color, -1);

			double sumRegion = 0;
			double weightedXSum = 0;
			double weightedYSum = 0;
			int pixelCount = 0;

            cv::Mat nonZero;
            cv::findNonZero(filledImage, nonZero);
            for (int i = 0; i < nonZero.rows; i++) {
                cv::Point pt = nonZero.at<cv::Point>(i, 0);
                int row = pt.y;
                int col = pt.x;
                
                double original_val = 0;
                if (originalImage.type() == CV_8UC1) {
                    original_val = (double)originalImage.at<uchar>(row, col);
                } else if (originalImage.type() == CV_64F) {
                    original_val = originalImage.at<double>(row,col);
                } else if (originalImage.type() == CV_32F) {
                    original_val = (double)originalImage.at<float>(row, col);
                }

                pixelCount++;
                sumRegion += original_val;
                weightedXSum += ((double)row * original_val);
                weightedYSum += ((double)col * original_val);
            }
            
            std::cout << "xsum: " << weightedXSum << std::endl;
            std::cout << "ysum: " << weightedYSum << std::endl;
            std::cout << "sumRegion: " << sumRegion << std::endl;
            std::cout << "xbar: " << xbar << std::endl;
            std::cout << "ybar: " << ybar << std::endl;
            
			double xbar = weightedXSum / sumRegion;
			double ybar = weightedYSum / sumRegion;
			cv::Point2d new_pt = cv::Point2d(xbar, ybar);
			pts.push_back(new_pt);
        }
        
        
        return pts;
    }
}