#include "Debug.h"
#include <iostream>
#include <fstream>

namespace Debug
{

void printStats(cv::Mat mat, char* fileName)
{
    
    ofstream out_file;
    out_file.open(fileName);
    
    double min;
    double max;
    minMaxIdx(mat, &min, &max);
    
    int count = 0;
    string valueText = "";
    
    for (int i = 0; i < mat.rows; i++) {
        for (int j = 0; j < mat.cols; j++) {
            if (mat.type() == CV_8UC1) {
                int val = (int) mat.at<unsigned char>(i, j);
                if (val != 0) {
                    if (count < 100)
                        out_file << val << ",";
                    count++;
                }
            } else if (mat.type() == CV_32F) {
                float val = (float) mat.at<float>(i, j);
                if (val != 0) {
                    if (count < 100)
                        out_file << val << ",";
                    count++;
                }
            } else if (mat.type() == CV_64F) {
                double val = (double) mat.at<double>(i, j);
                if (val != 0) {
                    if (count < 100)
                        out_file << val << ",";
                    count++;
                }
            } else {
                cout << "Didn't understand matrix type! Type: \n" << mat.type() << "\n";
            }
        }
    }

    out_file.close();
}

void print(cv::Mat mat, int rows, int cols, char* name)
{
    cout << "Print to file: " << name << " Rows: " << rows << " Cols: " << cols << "\n";
    ofstream out_file;
    out_file.open(name);
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (mat.type() == CV_8UC1) {
                int val = (int) mat.at<unsigned char>(i, j);
                out_file << val << ",";
            } else if (mat.type() == CV_32F) {
                float val = (float) mat.at<float>(i, j);
                out_file << val << ",";
            } else if (mat.type() == CV_64F) {
                double val = (double) mat.at<double>(i, j);
                out_file << val << ",";
            } else {
                cout << "Didn't understand matrix type! Type: " << mat.type() << "\n";
            }
        }
    }

    out_file.close();

    
}
}
