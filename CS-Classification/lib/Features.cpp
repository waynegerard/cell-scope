#include "Features.h"
#include "MatrixOperations.h"
#include "Region.h"

namespace Features 
{

	Mat geometricFeatures(Mat binPatch)  
	{
		Mat geometricFeatures = Mat(14, 1, CV_8UC3);

		ContourContainerType contours;
		cv::vector<Vec4i> hierarchy;

		findContours(binPatch, contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
		if (contours.size() == 0) {
			return cv::Mat::zeros(14, 1, CV_8UC3);
		}
    
		std::map<const char*, float> regionProperties = Region::getProperties(contours, binPatch);
        
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

	cv::Mat makePatch(int row, int col, Mat original)
	{
		int row_start = (row - PATCH_SIZE / 2);
		int row_end = row + (PATCH_SIZE / 2);
		int col_start = (col - PATCH_SIZE / 2);
		int col_end = col + (PATCH_SIZE / 2);
        
		Mat patchMatrix = original(cv::Range(row_start, row_end), cv::Range(col_start, col_end));
		return patchMatrix;
	}
    
    cv::Mat calculateBinarizedPatch(cv::Mat origPatch)
    {   
        // Calculate binarized patch using Otsu threshold.
        std::cout << "Calculating binarize patch" << std::endl;
        int rows = origPatch.rows;
        int cols = origPatch.cols;
        
        cv::Mat binPatchNew = cv::Mat(rows, cols, CV_32F);
        cv::Mat preThresh = cv::Mat(rows, cols, CV_8UC1);
        cv::Mat junk = cv::Mat(rows, cols, CV_8UC1);
        
		bool is_float = origPatch.type() == CV_32F;

        float maxVal = origPatch.at<float>(rows/2, cols/2);
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                float matVal = origPatch.at<float>(i, j);
                float val = MIN(matVal, maxVal);
                val = matVal / maxVal;
                preThresh.at<uchar>(i, j) = (int)val;
            }
        }
        
        // compute optimal Otsu threshold
        double thresh = cv::threshold(preThresh,junk,0,255,CV_THRESH_BINARY | CV_THRESH_OTSU);
        
        // apply threshold
        cv::threshold(preThresh,binPatchNew,thresh,255,CV_THRESH_BINARY_INV);
        
        ContourContainerType newContours;
        
        cv::findContours(binPatchNew, newContours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
        std::vector<cv::Point2d> allCenters = MatrixOperations::findWeightedCentroids(newContours, binPatchNew, origPatch);
        
        std::vector<cv::Point2d>::const_iterator it = allCenters.begin();
        std::vector<double> distances;
        
        double minDist = 1E10;
        int index = 0;
        std::vector<int> patchIndices;
        
        for (; it != allCenters.end(); it++) {
            cv::Point2d center = *it;
            double patchValue = (rows / 2) + 0.5;
            double x = pow((it->x - patchValue), 2);
            double y = pow((it->y - patchValue), 2);
            
            double distance = pow(x + y, 0.5);
            
            if (distance < minDist) {
                minDist = distance;
            }
            
        }
        
        for (it = allCenters.begin(); it != allCenters.end(); it++) {
            double patchValue = (rows / 2) + 0.5;
            double x = pow((it->x - patchValue), 2);
            double y = pow((it->y - patchValue), 2);
            
            double distance = pow(x + y, 0.5);
            
            if (distance == minDist) {
                patchIndices.push_back(index);
            }
            
            index++;
        }
        
        index = 0;
        ContourContainerType::const_iterator cit = newContours.begin();
        for (; cit != newContours.end(); cit++) {
            ContourType contour = *cit;
            
            std::vector<int>::const_iterator pit = patchIndices.begin();
            bool inIndices = false;
            for (; pit != patchIndices.end(); pit++) {
                if (inIndices) {
                    break;
                }
                if (*pit == index) {
                    inIndices = true;
                }
            }
            if (!inIndices) {
                ContourType::const_iterator rit = contour.begin();
                for (; rit != contour.end(); rit++) {
                    cv::Point pt = *rit;
                    binPatchNew.at<float>(pt.x, pt.y) = 0;
                }
            }
            
            index++;
        }
        
        return binPatchNew;
    }

    void calculateFeatures(vector<MatDict > blobs)
    {
        vector<MatDict >::const_iterator it = blobs.begin();
        
        for (; it != blobs.end(); ++it)
        {
            MatDict p = *it;
			Mat patch = p.find("patch")->second;
        
			// Calculate the hu moments
			Moments m = cv::moments(patch);
            double huMomentsArr[7];
			HuMoments(m, huMomentsArr);
            cv::Mat huMoments = cv::Mat(8,1,CV_64F);
            for (int j = 0; j < 7; j++)
            {
               huMoments.at<double>(j, 0) = huMomentsArr[j];
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
            
            huMoments.at<double>(7, 0) = nu40 - 2 * nu22 + nu04;
            
            
			// Grab the geometric features and return
            Mat binPatch = p.find("binPatch")->second;
            Mat geom = geometricFeatures(binPatch);
			p["geom"] = geom;
			p["phi"] = huMoments;
        }
    }

}