#include "Blob.h"
#include "Classifier.h"
#include "ImageTools.h"
#include "Debug.h"

namespace Classifier 
{

	cv::Mat initializeImage(cv::Mat image) 
	{
		cout << "Running with image\n";
		if(!image.data) {
            cout << "Image has no data! Returning.\n";
			return false;
		}
        
		// Convert to a red-channel normalized image if necessary
		if (image.type() == CV_8UC3) {
			image = ImageTools::getRedChannel(image);
		}
        
        cout << "Normalizing image\n";
		cv::Mat normalizedImage = ImageTools::normalizeImage(image);
		return normalizedImage;
	}

	cv::Mat objectIdentification(cv::Mat image)
	{
		cout << "Performing object identification\n";
		cv::Mat imageBw = Blob::blobIdentification(image);
		return imageBw;
	}

	cv::Mat featureDetection(cv::Mat imageBw)
	{
		ContourContainerType contours;
		cv::vector<cv::Vec4i> hierarchy;
		cv::findContours(imageBw, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
		int numObjects = contours.size();
    
		// Get the Hu moments
		cv::vector<Moments> mu(numObjects);
		for(int i = 0; i < numObjects; i++ )
		{ 
			mu[i] = cv::moments(contours[i], false); 
		}
    
		//  Get the mass centers
		vector<Point2f> centroids(contours.size());
		for (int i = 0; i < numObjects; i++) {
			float x = mu[i].m10 / mu[i].m00;
			float y = mu[i].m01 / mu[i].m00;
			Point2f pt = Point2f(x, y);
			centroids.push_back(pt);
		}
    
		int patchCount = 0;
		
		// Remove partial patches
		vector<std::Map> stats;
		for (int i = 0; i < numObjects; j++) {
			Point2f pt = centroids[i];
			float col = pt.x;
			float row = pt.y; 
			
			bool partial = Features::checkPartialPatch(row, col, patchSize, maxRow, maxCol);
			if (!partial)
			{
				std::map stats = Features::storeGoodCentroids(row, col);
				patchCount++;
				stats.push_back(stats);
			}
		}
   
		// Calculate features
		cv::Mat data = Features::calculateFeatures(data);
	}


	bool runWithImage(cv::Mat image)
	{
		//cv::Mat normalizedImaged = initializeImage(image);
		//cv::Mat imageBw = objectIdentification(normalizedImage);
		
		// Feature detection
		cv::Mat imageBw = Debug::loadMatrix("imbw.txt", 1944, 2592, CV_8UC1);
		cv::Mat features = featureDetection(imageBw);
		
		return true;
	}
}