#include "Features.h"
#include "Region.h"

namespace Features 
{

	Mat geometricFeatures(Mat* binPatch)  
	{
		Mat geometricFeatures = Mat(14, 1, CV_8UC3);

		ContourContainerType contours;
		cv::vector<Vec4i> hierarchy;

		findContours(*binPatch, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
		if (contours.size() == 0) {
			return cv::Mat::zeros(14, 1, CV_8UC3);
		}
    
		std::map<const char*, float> regionProperties = Region::getProperties(contours, *binPatch);
        
        int key_count = 14;
		const char* keys[] = {"area", "convexArea", "eccentricity", "equivDiameter", "extent", "filledArea",
            "minorAxisLength", "majorAxisLength", "maxIntensity", "minIntensity",
            "meanIntensity", "perimeter", "solidity", "eulerNumber"};

		for (int i = 0; i < key_count; i++) {
            const char* key = keys[i];
            float val = regionProperties.at(key);
			geometricFeatures.at<float>(0, i) = val;
		}
    
    
		return geometricFeatures;    
	}

	bool checkPartialPatch(int row, int col, int patchSize, int maxRow, int maxCol)
	{
		bool partial = false;
    
		// Lower bounds checking
		int lowerC = col - patchSize / 2;
		int lowerR = row - patchSize / 2;
		if (lowerC <= 0 || lowerR <= 0) {
			partial = true;
		}
    
		// Higher bounds checking
		int higherC = (col + (patchSize / 2 - 1));
		int higherR = (row + (patchSize / 2 - 1));
    
		if ((higherC > maxCol) || (higherR  > maxRow)) {
			partial = true;
		}

		return partial;
	}

	Patch* makePatch(int row, int col, Mat original)
	{
		// Indices in matlab are 1 based
		int row_start = (row - PATCH_SIZE / 2) - 1;
		int row_end = row + (PATCH_SIZE / 2 - 1) - 1;
		int col_start = col - PATCH_SIZE / 2 - 1;
		int col_end = col + (PATCH_SIZE / 2 - 1) - 1;
		Range rows = Range(row_start, row_end);
		Range cols = Range(col_start, col_end);
    
		Mat patchMatrix = original.operator()(rows, cols);
		Patch* patch = new Patch(row, col, patchMatrix);
    
		return patch;
	}


    void calculateFeatures(vector<Patch*> blobs)
    {
       for (int i = 0; i < blobs.size(); i++)
       {
			Patch* p = blobs.at(i * sizeof(Patch*));
			Mat* patch = p->getPatch();
        
			// Calculate the hu moments
			Moments m = cv::moments(*patch);
            double huMomentsArr[7];
			HuMoments(m, huMomentsArr);
           cv::Mat* huMoments = new cv::Mat(7,1,CV_64F);
           for (int j = 0; j < 7; j++)
           {
               huMoments->at<double>(j, 0) = huMomentsArr[j];
           }
        
			// Grab the geometric features and return
            Mat* binPatch = p->getBinPatch();
            Mat* geom = new Mat(geometricFeatures(binPatch));
            p->setGeom(*geom);
            p->setPhi(*huMoments);
        }
    }

}