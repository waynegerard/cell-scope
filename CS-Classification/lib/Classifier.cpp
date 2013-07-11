#include "Blob.h"
#include "Classifier.h"
#include "Features.h"
#include "ImageTools.h"
#include "Patch.h"
#include <fstream>

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

    cv::Mat loadCSV(const char* file_path)
    {
        Vector<double> vec;
        
		ifstream inFile(file_path);
        string value;
        while ( inFile.good() )
        {
            getline (inFile, value, ',');
            double val = atof((char*)value.c_str());
            vec.push_back(val);
        }
        
        cv::Mat returnMatrix = cv::Mat(1, (int)vec.size(), CV_64F);
        
        Vector<double>::iterator it = vec.begin();
        int i = 0;
		for(; it != vec.end(); it++)
		{
            returnMatrix.at<double>(0, i) = *it;
            i++;
		}

        return returnMatrix;
    }
    
    cv::Mat repMat(cv::Mat matrix, int multiplier)
    {
        cv::Mat returnMatrix = cv::Mat(multiplier, matrix.cols, matrix.type());
        for (int i = 0; i < returnMatrix.rows; i++)
        {
            for (int j = 0; j < returnMatrix.cols; j++)
            {
                returnMatrix.at<double>(i, j) = matrix.at<double>(0, j);
            }
        }
        return returnMatrix;
    }
    
    vector<double> classifyObjects(vector<Patch*> features)
    {
        
        // Load the SVM
        svm_model *model = svm_load_model(MODEL_PATH);
        Mat train_max = loadCSV(TRAIN_MAX_PATH);
        Mat train_min = loadCSV(TRAIN_MIN_PATH);

        /*
        // Combine the features and make the zeros matrix
        cv::Mat featuresMatrix = cv::Mat((int)features.size(), 21, CV_32F);
        
        vector<Patch*>::const_iterator it = features.begin();
        int row = 0;
        for (; it != features.end(); it++)
        {
            Patch* patch = *it;
            cv::Mat geom = patch->getGeom();
            cv::Mat phi = patch->getPhi();
            int i = 0;
            for (; i < phi.rows; i++)
            {
                featuresMatrix.at<float>(row, i) = phi.at<float>(i, 1);
            }
            for (; i < geom.rows; i++)
            {
                featuresMatrix.at<float>(row, i) = geom.at<float>(i, 1);
            }
            row++;
        }
         */
        
        // Should intercept here and add a loading for the entire featuresMatrix
        cv::Mat featuresMatrix = Debug::loadMatrix("xtest.txt", 120, 22, CV_64F);
    
        // minmax normalization of features
        cv::Mat maxMatrix = repMat(train_max, featuresMatrix.rows);
        cv::Mat minMatrix = repMat(train_min, featuresMatrix.rows);
                
        cv::Mat testMatrix = cv::Mat(featuresMatrix.rows, featuresMatrix.cols, featuresMatrix.type());
        cv::Mat numerator = cv::Mat(featuresMatrix.rows, featuresMatrix.cols, featuresMatrix.type());
        cv::Mat denominator = cv::Mat(featuresMatrix.rows, featuresMatrix.cols, featuresMatrix.type());
        cv::subtract(featuresMatrix, minMatrix, numerator);
        cv::subtract(maxMatrix, minMatrix, denominator);
        cv::divide(numerator, denominator, testMatrix);
        
        // Classify objects and get probabilities
        vector<double> prob_results;
        
        for (int i = 0; i < testMatrix.rows; i++) {

            svm_node *node = new svm_node[testMatrix.cols + 2];
            for (int j = 0; j < testMatrix.cols; j++) {
                double d = testMatrix.at<double>(i, j);
                node[j].index = j+1;
                node[j].value = d;
            }
            node[testMatrix.cols].index = -1;
            node[testMatrix.cols].value = 0;
            
            double *probabilities = new double[2];
            double result_prob = svm_predict_probability(model, node, probabilities);
            prob_results.push_back(probabilities[0]);
        }
        
        cout << "Finished classifying features" << endl;
        return prob_results;
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
		//cv::Mat imageBw = Debug::loadMatrix("imbw.txt", 1944, 2592, CV_8UC1);
        //vector<Patch*> features = featureDetection(imageBw);
        //Debug::printFeatures(features, "origPatch");

        // Classify Objects
        vector<Patch*> features;
        vector<double> prob_results = classifyObjects(features);
        Debug::printVector(prob_results, "dvtest.txt");
        
        /*
        // Sort Scores and Centroids
        _sortedScores = [self sortScoresWithArray:scoreDictionaryArray];
        
        // Drop Low-confidence Patches
        Patch* patch = [[Patch alloc] init];
        NSMutableIndexSet* lowConfidencePatches = [patch findLowConfidencePatches];
        [_sortedScores removeObjectsAtIndexes:lowConfidencePatches];
        [_centroids removeObjectsAtIndexes:lowConfidencePatches];
        
        // Non-max Suppression Based on Scores
        NSMutableIndexSet* suppressedPatches = [patch findSuppressedPatches];
        [_sortedScores removeObjectsAtIndexes:suppressedPatches];
        [_centroids removeObjectsAtIndexes:suppressedPatches];
        */

		return true;
	}
}