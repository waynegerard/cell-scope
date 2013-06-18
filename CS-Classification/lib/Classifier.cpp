#include "Blob.h"
#include "Classifier.h"
#include "ImageTools.h"
#include "Debug.h"

namespace Classifier 
{
	bool runWithImage(cv::Mat image)
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
		cv::Mat originalImage = ImageTools::normalizeImage(image);
        Debug::print(originalImage, originalImage.rows, originalImage.cols, "/Users/wgerard/Dev/cell-scope/CS-Classification/Xcode/CellScope-Test/output/orig.txt");
        
		// Perform object identification
        cout << "Performing object identification\n";
		cv::Mat imageBw = Blob::blobIdentification(originalImage);
    
		//CSLog(@"Finished object identification");
		ContourContainerType contours;
		cv::vector<cv::Vec4i> hierarchy;
		cv::findContours(imageBw, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    
		// Get the Hu moments
		//cv::vector<Moments> mu(contours.size() );
		//for( int i = 0; i < contours.size(); i++ )
		//{ mu[i] = cv::moments( contours[i], false ); }
		return true;
	}
}