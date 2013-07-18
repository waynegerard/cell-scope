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

	bool checkPartialPatch(int row, int col, int maxRow, int maxCol)
	{
		bool partial = false;
    
		// Lower bounds checking
		int lowerC = col - PATCH_SIZE / 2;
		int lowerR = row - PATCH_SIZE / 2;
		if (lowerC <= 0 || lowerR <= 0) {
			partial = true;
		}
    
		// Higher bounds checking
		int higherC = (col + (PATCH_SIZE / 2 - 1));
		int higherR = (row + (PATCH_SIZE / 2 - 1));
    
		if ((higherC > maxCol) || (higherR  > maxRow)) {
			partial = true;
		}

		return partial;
	}

	Patch* makePatch(int row, int col, Mat original)
	{
		int row_start = (row - PATCH_SIZE / 2);
		int row_end = row + (PATCH_SIZE / 2);
		int col_start = (col - PATCH_SIZE / 2);
		int col_end = col + (PATCH_SIZE / 2);
		Range rows = Range(row_start, row_end);
		Range cols = Range(col_start, col_end);
    
		Mat patchMatrix = *new Mat(original.operator()(rows, cols));
		Patch* patch = new Patch(row, col, patchMatrix);
        patch->calculateBinarizedPatch();
    
		return patch;
	}
    
    double momentpq(Mat image, int p, int q, double xc, double yc)
    {
        double sum = 0;
        for (int i = 0; i < image.rows; i++)
        {
            for (int j = 0; j < image.cols; j++)
            {
                // x = i, y = j
                double val = image.at<double>(i, j);
                double colVal = pow((j - yc), q);
                double rowVal = pow((i - xc), p);
                double next = rowVal * colVal * val;
                sum += next;
                
            }
        }
        return sum;
    }
    

    void calculateFeatures(vector<Patch*> blobs)
    {
        vector<Patch*>::const_iterator it = blobs.begin();
        
        for (; it != blobs.end(); ++it)
        {
            Patch* p = *it;
			Mat patch = p->getPatch();
        
			// Calculate the hu moments
			Moments m = cv::moments(patch);
            double huMomentsArr[7];
			HuMoments(m, huMomentsArr);
            cv::Mat* huMoments = new cv::Mat(8,1,CV_64F);
            for (int j = 0; j < 7; j++)
            {
               huMoments->at<double>(j, 0) = huMomentsArr[j];
            }
        
            // Phi_11 moment
            double xc = m.m10 / m.m00;
            double yc = m.m01 / m.m00;
            
            double mu40 = momentpq(patch, 4, 0, xc, yc);
            double mu22 = momentpq(patch, 2, 2, xc, yc);
            double mu04 = momentpq(patch, 0, 4, xc, yc);
            
            double nu40 = mu40 / pow(m.m00, 3);
            double nu22 = mu22 / pow(m.m00, 3);
            double nu04 = mu04 / pow(m.m00, 3);
            
            huMoments->at<double>(7, 0) = nu40 - 2 * nu22 + nu04;
            
            
			// Grab the geometric features and return
            //Mat* binPatch = p->getBinPatch();
            //Mat* geom = new Mat(geometricFeatures(binPatch));
            //p->setGeom(*geom);
            p->setPhi(*huMoments);
        }
    }

}