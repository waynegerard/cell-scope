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
        Vector<float> vec;
        
		ifstream inFile(file_path);
        string value;
        while ( inFile.good() )
        {
            getline (inFile, value, ',');
            value = string(value, 1, value.length()-2); // Remove quotes
            float val = atof((char*)value.c_str());
            vec.push_back(val);
        }
        
        cv::Mat returnMatrix = cv::Mat(1, (int)vec.size(), CV_32F);
        
        Vector<float>::iterator it = vec.begin();
        int i = 0;
		for(; it != vec.end(); it++)
		{
            returnMatrix.at<float>(0, i) = *it;
            i++;
		}

        return returnMatrix;
    }
    
    void prepareFeatures()
    {
     
        // Prepare features
        cv::Mat zeroMatrix = cv::Mat::zeros(PATCH_SIZE, 1, CV_8UC1);
        /*
         for t = 1:data.NumObjects
         ctrs(t,:) = [data.stats(t).row data.stats(t).col];
         
         if dohog
         feats(t,:) = [data.stats(t).phi data.stats(t).geom data.stats(t).hog];
         else
         feats(t,:) = [data.stats(t).phi data.stats(t).geom];
         end
         binpatches{1,t} = data.stats(t).binpatch;
         patches{1,t} = data.stats(t).patch;
         end
         
         % Prepare features and run object-level classifier
         Xtest = feats;
         ytest_dummy = zeros(size(Xtest,1),1);
         
         % Minmax normalization of features
         maxmat = repmat(train_max,size(ytest_dummy));
         minmat = repmat(train_min,size(ytest_dummy));
         Xtest = (Xtest-minmat)./(maxmat-minmat);
         */
        
        
        // WAYNE:
        // Two problems: repMat is not respecting the rows
        // features should not have 0 columns

        // Minmax normalization of features
        Mat train_max = loadCSV(TRAIN_MAX_PATH);
        Mat train_min = loadCSV(TRAIN_MIN_PATH);
        
        int rows = _features->rows;
        int cols = _features->cols;
        Mat maxMatrix = [MatrixOperations repMat:train_max withRows:rows withCols:cols];
        Mat minMatrix = [MatrixOperations repMat:train_min withRows:rows withCols:cols];
        
        Mat FeaturesMinusMin;
        Mat MaxMinusMin;
        subtract(maxMatrix, minMatrix, MaxMinusMin);
        subtract(*_features, minMatrix, FeaturesMinusMin);
        
        
        Mat featuresMatrix = Mat(FeaturesMinusMin.rows, FeaturesMinusMin.cols, CV_8UC1);
        divide(FeaturesMinusMin, MaxMinusMin, featuresMatrix);
        
        return featuresMatrix;
    
    }
    
    void classifyObjects()
    {
        
        // Load the SVM
        svm_model *model = svm_load_model(MODEL_PATH);
        

        Mat train_max;
        Mat train_min;
        
        // Classify Objects with LibSVM IKSVM classifier
        //svm_predict(<#const struct svm_model *model#>, <#const struct svm_node *x#>);
        //*** NOT WORKING - Waiting on test data*** [pltest, accutest, dvtest] = svmpredict(double(yTest),double(Xtest),model,'-b 1');
        NSMutableArray* dvtest = [NSMutableArray array];
        //*** NOT WORKING  - Waiting on test data*** dvtest = dvtest(:,model.Label==1);
        NSMutableArray* scoreDictionaryArray = [NSMutableArray array];
        
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
        Debug::printFeatures(features, "origPatch");

        // Classify Objects
        
        
        
		return true;
	}
}