//
//  Globals.h
//  CellScope
//
//  Created by Wayne Gerard on 12/23/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#include <opencv2/core/core.hpp>

#ifndef CellScope_Globals_h
#define CellScope_Globals_h

#define DEBUG 1

#ifdef DEBUG
#   define CSLog(fmt, ...) NSLog((@"%s %s [Line %d] " fmt), __FILE__, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define CSLog(...) ;
#endif

typedef cv::vector<cv::vector<cv::Point> > contourContainer;
typedef cv::vector<cv::Point> contour;

#endif
