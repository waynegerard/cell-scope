//
//  Blobid.m
//  CellScope
//
//  Created by Wayne Gerard on 12/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "Blobid.h"

@implementation Blobid

- (cv::Mat) getMorphologicalOpeningWithImg: (cv::Mat&) img {

    
    // The morphological open operation is an erosion followed by a dilation, using the same structuring element for both operations.
    
    
    //imbigop=imopen(orig,strel('square',10));
    cv::Mat imBigOp;
    cv::Mat imdf;
    cv::subtract(img, imBigOp, imdf);
    //imdf=orig-imbigop;
    //imthresh=imdf>(mean(imdf(:)) + 3 * std(imdf(:)));
}


/**
    Simple function that finds blobs in a grayscale image
 */
- (void) blobIDWithImage: (cv::Mat&) img {
    
    cv::Mat imbw;
    
    cv::Mat imThreshold = [self getMorphologicalOpeningWithImg:img];
    
    // Combine the xcorr and morphological opening outputs
    //imbw = imbw_xcorr & imthresh;
    //imbw = imclose(imbw,strel('square',3));
    return imbw;
}

@end
