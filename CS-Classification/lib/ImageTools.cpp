#include "ImageTools.h"
#include "opencv2/imgproc/imgproc.hpp"

namespace ImageTools
{
	cv::Mat getRedChannel(cv::Mat image) 
	{
		cv::Mat red(image.rows, image.cols, CV_8UC1);
		cv::Mat junk(image.rows, image.cols, CV_8UC2);
    
		cv::Mat output[] = { red, junk };
		int index_map[] = { 0,0, 1,1, 2,2 };
		cv::mixChannels(&image, 1, output, 2, index_map, 3);
    
		return red;
	}


	cv::Mat normalizeImage(cv::Mat image) 
	{
		cv::Mat img_32F(image.rows, image.cols, CV_32F);
		cv::Mat res(image.rows, image.cols, CV_32F);
    
		image.convertTo(img_32F, CV_32F);
		double max;
		double min;
		cv::minMaxIdx(image, &min, &max);
    
		for (int i = 0; i < img_32F.rows; i++) {
			for (int j = 0; j < img_32F.cols; j++) {
				float val = img_32F.at<float>(i, j);
				val = val / (float)max;
				img_32F.at<float>(i, j) = val;
			}
		}
    
		return img_32F;
	}
}