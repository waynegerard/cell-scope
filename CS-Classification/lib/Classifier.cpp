#include "Blob.h"
#include "Classifier.h"
#include "Features.h"
#include "ImageTools.h"
#include "Patch.h"
#include "Debug.h"

namespace Classifier 
{

	cv::Mat initializeImage(cv::Mat image) 
	{        
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

	vector<Patch*> featureDetection(cv::Mat imageBw)
	{
		ContourContainerType contours;
		cv::vector<cv::Vec4i> hierarchy;
		cv::findContours(imageBw, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
		unsigned long numObjects = contours.size();
        cout << "Found " << numObjects << " Contours in image" << endl;
        
		// Get the Hu moments
        cout << "Calculating Hu moments..." << endl;
		cv::vector<Moments> mu;
        
        ContourContainerType::iterator c_it = contours.begin();
		for(; c_it != contours.end(); c_it++)
		{
            ContourType ctr = *c_it;
			mu.push_back(cv::moments(ctr, false));
		}
    
		//  Get the mass centers
        cout << "Calculating mass centers..." << endl;
        cv::vector<Point> centroids;
        cv::vector<Moments>::iterator m_it = mu.begin();
		for (; m_it != mu.end(); m_it++) {
            Moments val = *m_it;
            if (val.m00 != 0)
            {
                int x = (int) (val.m10 / val.m00);
                int y = (int) (val.m01 / val.m00);
                Point pt = *new Point(x, y);
                centroids.push_back(pt);
            }
		}
    
		int patchCount = 0;
		
		// Remove partial patches
        cout << "Removing partial patches..." << endl;
		vector<Patch*> stats;
        
        vector<Point>::iterator it = centroids.begin();
        for (; it != centroids.end(); ++it) {
			Point2d pt = *it;
            int col = (int)pt.x;
			int row = (int)pt.y;
			
			bool partial = Features::checkPartialPatch(row, col, imageBw.rows, imageBw.cols);
			if (!partial)
			{
                Patch* p = Features::makePatch(row, col, imageBw);
				patchCount++;
				stats.push_back(p);
			}
		}
        cout << "Final patch count: " << patchCount << endl;
   
		// Calculate features
		Features::calculateFeatures(stats);
        return stats;
	}


	bool runWithImage(cv::Mat image)
	{
        cout << "Running with image\n";
		if(!image.data) {
            cout << "Image has no data! Returning.\n";
			return false;
		}

		//cv::Mat normalizedImaged = initializeImage(image);
		//cv::Mat imageBw = objectIdentification(normalizedImage);
		
		// Feature detection
		cv::Mat imageBw = Debug::loadMatrix("imbw.txt", 1944, 2592, CV_8UC1);
        cv::vector<Patch*> features = featureDetection(imageBw);
		
		return true;
	}
}