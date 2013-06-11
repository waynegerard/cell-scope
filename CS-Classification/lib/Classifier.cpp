#include "Blob.h"
#include "Classifier.h"
#include "ImageTools.h"
#include "Globals.h"

namespace Classifier 
{
	void runWithImage (cv::Mat image)
	{   
		if(!image.data) {
			return;
		}
    
		// Convert to a red-channel normalized image if necessary
		if (image.type() == CV_8UC3) {
			image = ImageTools::getRedChannel(image);
		}
		cv::Mat originalImage = ImageTools::normalizeImage(image);
		// Perform object identification
		cv::Mat imageBw = Blob::blobIdentification(originalImage);
    
		//CSLog(@"Finished object identification");
		ContourContainerType contours;
		cv::vector<cv::Vec4i> hierarchy;
		cv::findContours(imageBw, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    
		// Get the Hu moments
		//cv::vector<Moments> mu(contours.size() );
		//for( int i = 0; i < contours.size(); i++ )
		//{ mu[i] = cv::moments( contours[i], false ); }
	}
}