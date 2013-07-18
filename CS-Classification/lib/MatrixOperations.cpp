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
    
    std::vector<cv::Point> findWeightedCentroids(ContourContainerType contours, cv::Mat mat)
    {
        std::vector<cv::Point> pts;

        for (int i = 0; i < contours.size(); i++)
        {
            cv::Mat filledImage = cv::Mat::zeros(mat.rows, mat.cols, mat.type());
            cv::drawContours(filledImage, contours, i, 255, -1);

            /*
             //FilledImage: draw the region on in white
             cv2.drawContours( filledI, cs, i, color=255, thickness=-1 )
             //calculate indices of that region..
             regionMask    = (filledI==255)
             
             //PixelIdxList : indices of region.
             //(np.array of xvals, np.array of yvals)
             PixelIdxList  = regionMask.nonzero()
             //pixel values
             PixelValues   = img[regionMask]
             */

        }
        
        
        return pts;
    }
}