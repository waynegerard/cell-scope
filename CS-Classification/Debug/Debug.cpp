#include "Debug.h"
#include <iostream>
#include <cstring>
#include <fstream>

namespace Debug
{

	void printStats(cv::Mat mat, const char* fileName)
	{
		string path = OUTPUT_FOLDER;
		path += fileName;
		char* full_path = (char*)path.c_str();

		ofstream out_file;
		out_file.open(full_path);
    
		double min;
		double max;
		minMaxIdx(mat, &min, &max);
    
		int count = 0;
		string valueText = "";
    
		for (int i = 0; i < mat.cols; i++) {
			for (int j = 0; j < mat.rows; j++) {
				if (mat.type() == CV_8UC1) {
					int val = (int) mat.at<unsigned char>(j, i);
					if (val != 0) {
						if (count < 100)
							out_file << val << ",";
						count++;
					}
				} else if (mat.type() == CV_32F) {
					float val = (float) mat.at<float>(j, i);
					if (val != 0) {
						if (count < 100)
							out_file << val << ",";
						count++;
					}
				} else if (mat.type() == CV_64F) {
					double val = (double) mat.at<double>(j, i);
					if (val != 0) {
						if (count < 100)
							out_file << val << ",";
						count++;
					}
				} else {
					cout << "Didn't understand matrix type! Type: " << mat.type() << endl;
				}
			}
		}

		out_file.close();
	}

	void print(cv::Mat mat, const char* name)
	{
		string path = OUTPUT_FOLDER;
		path += name;
		char* full_path = (char*)path.c_str();
    
		cout << "Print to file: " << name << " Rows: " << mat.rows << " Cols: " << mat.cols << endl;
		cout << "Fullpath: " << full_path << endl;
		ofstream out_file;
		out_file.open(full_path);
    
		if (!out_file) {
			cerr << "Can't open output file!" << endl;
		}
    
		for (int i = 0; i < mat.cols; i++) {
			for (int j = 0; j < mat.rows; j++) {
				if (mat.type() == CV_8UC1) {
					int val = (int) mat.at<unsigned char>(j, i);
					out_file << val << ",";
				} else if (mat.type() == CV_32F) {
					float val = (float) mat.at<float>(j, i);
					out_file << val << ",";
				} else if (mat.type() == CV_64F) {
					double val = (double) mat.at<double>(j, i);
					out_file << val << ",";
				} else {
					cout << "Didn't understand matrix type! Type: " << mat.type() << endl;
				}
			}
		}

		out_file.close();

    
	}

	Mat loadMatrix(const char* fileName, int rows, int cols, int type)
	{
		Mat returnMatrix = Mat(rows, cols, type);

		string path = MATLAB_FOLDER;
		path += fileName;
		char* full_path = (char*)path.c_str();

		cout << "Opening path: " << full_path << endl;

		string line;
		ifstream inFile(full_path);
		if (inFile.is_open())
		{
			for (int i = 0; i < cols; i++) 
			{
				for (int j = 0; j < rows; j++) 
				{
					getline(inFile, line);

					if (type == CV_32F) {
						float val = ::atof(line.c_str());
						returnMatrix.at<float>(j, i) = val;
					} else if (type == CV_8UC1) {
						int val = ::atoi(line.c_str());
						returnMatrix.at<uchar>(j, i) = (uchar)val;
					} else {
						cout << "Didnt understand type: " << type << endl;
					}
				}
			}
			cout << "Closing file: " << full_path << endl;
			inFile.close();
		}
		else cout << "Unable to open file: " << fileName; 

		return returnMatrix;
	}
}
