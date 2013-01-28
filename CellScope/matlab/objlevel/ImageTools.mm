//
//  ImageTools.m
//  CellScope
//
//  Created by Wayne Gerard on 12/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "ImageTools.h"
#import <opencv2/imgproc/imgproc.hpp>

@implementation ImageTools


+ (Mat)cvMatWithImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    Mat cvMat(rows, cols, CV_8UC3); // 8 bits per component, 3 channels (RGB)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

cv::vector <cv::vector<cv::Point> > findBlobs(const cv::Mat &img)
{
    cv::vector <cv::vector<cv::Point> > blobs;
    blobs.clear();
    
    // Using labels from 2+ for each blob
    cv::Mat label_image;
    img.convertTo(label_image, CV_32FC1);
    
    int label_count = 2; // starts at 2 because 0,1 are used already
    
    for(int row = 0; row < img.rows; row++) {
        for(int col = 0; col < img.cols; col++) {
            
            if( (int)label_image.at<int>(row,col) != 1) {
                continue;
            }
            
            cv::Rect rect;
            cv::floodFill(label_image, cv::Point(row,col), cv::Scalar(label_count), &rect, cv::Scalar(0), cv::Scalar(0), 4);
            
            cv::vector<cv::Point> blob;
            
            for(int i=rect.y; i < (rect.y+rect.height); i++) {
                for(int j=rect.x; j < (rect.x+rect.width); j++) {
                    if((int)label_image.at<int>(i,j) != label_count) {
                        continue;
                    }
                    blob.push_back(cv::Point(j,i));
                }
            }
            blobs.push_back(blob);
            label_count++;
        }
    }
    return blobs;
}

@end
