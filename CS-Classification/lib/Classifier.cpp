#include "BlobClass.h"
#include "Classifier.h"
#include "Features.h"
#include "ImageTools.h"
#include "MatrixOperations.h"
#include <fstream>

#include "Debug.h"
#include <time.h>

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
		cv::Mat imageBw = BlobClass::blobIdentification(image);
		return imageBw;
	}

	vector<MatDict > featureDetection(cv::Mat imageBw, cv::Mat original)
	{
        
		ContourContainerType contours;
		cv::vector<cv::Vec4i> hierarchy;
		cv::findContours(imageBw, contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
        
		unsigned long numObjects = contours.size();
        cout << "Found " << numObjects << " Contours in image" << endl;
        
		vector<cv::Point2d> centroids = MatrixOperations::findWeightedCentroids(contours,imageBw,original);
   
        //vector<Point> centroids = Debug::loadCentroids();
		int patchCount = 0;
		
		// Remove partial patches
        cout << "Removing partial patches..." << endl;
		vector<MatDict > stats;
        
        vector<cv::Point2d>::iterator it = centroids.begin();
        for (; it != centroids.end(); ++it) {
            cv::Point pt = *it;
			int row = (int)pt.x;
            int col = (int)pt.y;
			
			bool partial = Features::checkPartialPatch(row, col, imageBw.rows, imageBw.cols);
			if (!partial)
			{
				cv::Mat rowMat = cv::Mat(1, 1, CV_32F);
				cv::Mat colMat = cv::Mat(1, 1, CV_32F);
				rowMat.at<float>(0, 0) = (float)row;
				colMat.at<float>(0, 0) = (float)col;
				
                cv::Mat patch = *new cv::Mat(Features::makePatch(row, col, original));
                cv::Mat binPatch = *new cv::Mat(Features::calculateBinarizedPatch(patch));
				MatDict data;

				data.insert(std::pair<const char*, cv::Mat>("row", rowMat));
				data.insert(std::pair<const char*, cv::Mat>("col", colMat));
				data.insert(std::pair<const char*, cv::Mat>("patch", patch));
				data.insert(std::pair<const char*, cv::Mat>("binPatch", binPatch));
				patchCount++;

				stats.push_back(data);
			}
		}
        cout << "Final patch count: " << patchCount << endl;
        
		// Calculate features
		stats = Features::calculateFeatures(stats);
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
    
    vector<double> classifyObjects(vector<MatDict > features, const char* model_path, const char* max_path, const char* min_path)
    {
        
        // Load the SVM
        svm_model *model;
        Mat train_max;
        Mat train_min;
        if (DEBUG) {
            *model = *svm_load_model(MODEL_PATH);
            train_max = loadCSV(TRAIN_MAX_PATH);
            train_min = loadCSV(TRAIN_MIN_PATH);
        } else {
            model = svm_load_model(model_path);
            train_max = loadCSV(max_path);
            train_min = loadCSV(min_path);
        }

        // Combine the features
        cv::Mat featuresMatrix = cv::Mat((int)features.size(), 22, CV_64F);
        
        vector<MatDict >::const_iterator it = features.begin();
        int row = 0;
        for (; it != features.end(); it++)
        {
            MatDict patch = *it;
            cv::Mat geom = patch.find("geom")->second;
            cv::Mat phi = patch.find("phi")->second;
            int index = 0;
            for (int i = 0; i < phi.rows; i++)
            {
				double val = phi.at<double>(i, 0);
                featuresMatrix.at<double>(row, index) = val;
				index++;
            }
            for (int i = 0; i < geom.rows; i++)
            {
				cv::Mat rowMat = patch.find("row")->second;
				cv::Mat colMat = patch.find("col")->second;
				float geom_val = geom.at<float>(i, 0);
                featuresMatrix.at<double>(row, index) = (double) geom_val;
				index++;
            }
            row++;
        }
        
        Debug::print(featuresMatrix, "xtest.txt");
    
        // minmax normalization of features
        cv::Mat maxMatrix = repMat(train_max, featuresMatrix.rows);
        cv::Mat minMatrix = repMat(train_min, featuresMatrix.rows);
                
        cv::Mat testMatrix = cv::Mat(featuresMatrix.rows, featuresMatrix.cols, featuresMatrix.type());
        cv::Mat numerator = cv::Mat(featuresMatrix.rows, featuresMatrix.cols, featuresMatrix.type());
        cv::Mat denominator = cv::Mat(featuresMatrix.rows, featuresMatrix.cols, featuresMatrix.type());
        cv::subtract(featuresMatrix, minMatrix, numerator);
        cv::subtract(maxMatrix, minMatrix, denominator);
        cv::divide(numerator, denominator, testMatrix);
        
		Debug::print(numerator, "numerator.txt");
        Debug::print(testMatrix, "xtest_final.txt");

		//testMatrix = Debug::loadMatrix("xtest_final.txt", 120, 22, CV_64F);
        
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
            svm_predict_probability(model, node, probabilities);
            prob_results.push_back(probabilities[0]);
        }
        
        cout << "Finished classifying features" << endl;
		Debug::printVector(prob_results, "dvtest.txt");
        return prob_results;
    }
    
    bool comparator ( const pair<double, int>& l, const pair<double, int>& r)
    { return l.first > r.first; };

    
    cv::Mat filterProbabilities(vector<double> prob_results, vector<MatDict > features, cv::Mat normalizedImage)
    {
        cv::Mat scores_and_centers;
        vector<std::pair<double, int> > prob_results_with_index;
        vector<double>::iterator it = prob_results.begin();
        int index = 0;
        for (; it != prob_results.end(); it++)
        {
            prob_results_with_index.push_back(make_pair(*it, index));
            index++;
        }
        
        sort(prob_results_with_index.begin(), prob_results_with_index.end(), comparator);
        Debug::printPairVector(prob_results_with_index, "dvtest_sorted.txt");
        
		int too_low = 0;
		index = 0;
		vector<pair<double, int> >::const_iterator pit = prob_results_with_index.begin();
        
		float max_distance = pow(pow(normalizedImage.rows, 2.0) + pow(normalizedImage.cols, 2.0), 0.5);
		for (; pit != prob_results_with_index.end(); pit++) {
			pair<double, int> score_with_index = *pit;
			double score = score_with_index.first;
			int score_index = score_with_index.second;
            
			if (score > 1E-6) {
				MatDict feature = features[score_index];
				cv::Mat rowMat = feature.find("row")->second;
				cv::Mat colMat = feature.find("col")->second;
				int row = (int) rowMat.at<float>(0, 0);
				int col = (int) colMat.at<float>(0, 0);
                
				float min_distance = max_distance;
				int min_index = 0;
				int counter = 0;
                
				vector<MatDict >::const_iterator fit = features.begin();
				for (; fit != features.end(); fit++) {
					MatDict other_feature = *fit;
					
					cv::Mat other_row_mat = other_feature.find("row")->second;
					cv::Mat other_col_mat = other_feature.find("col")->second;
					int other_row = (int) other_row_mat.at<float>(0, 0);
					int other_col = (int) other_col_mat.at<float>(0, 0);
                    
					if (other_row != row || other_col != col) {
						float distance = pow(pow(row - other_row, 2.0) + pow(col - other_col, 2.0), 0.5);
						if (distance < min_distance) {
							min_distance = distance;
							min_index = counter;
						}
					}
					counter++;
				}
                
				float too_close = 0.75 * PATCH_SIZE;
				if (min_distance <= too_close) {
					MatDict feature = features[min_index];
					cv::Mat close_feature_row = feature.find("row")->second;
					cv::Mat close_feature_col = feature.find("col")->second;
					close_feature_row.at<float>(0, 0) = -1 * normalizedImage.rows;
					close_feature_col.at<float>(0, 0) = -1 * normalizedImage.cols;
					feature.insert(std::pair<const char*, cv::Mat>("row", close_feature_row));
					feature.insert(std::pair<const char*, cv::Mat>("col", close_feature_col));
					features[min_index] = feature;
					too_close++;
				} else {
					scores_and_centers.create(index + 1, 3, CV_32F);
					scores_and_centers.at<float>(index, 0) = (float) score;
					scores_and_centers.at<float>(index, 1) = (float) row;
					scores_and_centers.at<float>(index, 2) = (float) col;
				}
			} else {
				too_low++;
			}
			index++;
		} 
        
        return scores_and_centers;
    }
    
	cv::Mat runWithImage(const cv::Mat image, const char* model_path, const char* max_path, const char* min_path)
	{
        std::cout << "Running with image\n";
		if(!image.data) {
            std::cout << "Image has no data! Returning.\n";
			return cv::Mat::zeros(1,1,CV_8UC1);
		}
        
        /** Start DEBUG code */
        cv::Mat thresholdImage;
        cv::threshold(image, thresholdImage, 254, 1, CV_THRESH_BINARY_INV);
        ContourContainerType contours;
        cv::findContours(thresholdImage, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
        clock_t t;
        t = clock();
        std::vector<cv::Point2d> centroids = MatrixOperations::findWeightedCentroids(contours, thresholdImage, image);
        t = clock() - t;
        printf ("It took me %d clicks (%f seconds).\n",t,((float)t)/CLOCKS_PER_SEC);
        std::vector<cv::Point2d>::iterator it = centroids.begin();
        
        for (; it != centroids.end(); it++) {
            cv::Point2d pt = *it;
            cout << "Point (x,y): " << pt.x << "," << pt.y << std::endl;
        }
        
        return cv::Mat(1,1,CV_8UC1);
        
        /** end DEBUG code */
        
		cv::Mat normalizedImage = initializeImage(image);
		cv::Mat imageBw = objectIdentification(normalizedImage);

		// Feature detection
		vector<MatDict > features = featureDetection(imageBw, normalizedImage);
		
        // Classify Objects
        vector<double> prob_results = classifyObjects(features, model_path, max_path, min_path);

        // Sort scores, keeping index
        cv::Mat scores_and_centers = filterProbabilities(prob_results, features, normalizedImage);
        
        return scores_and_centers;
	}
}
