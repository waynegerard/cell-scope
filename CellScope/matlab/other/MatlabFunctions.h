//
//  MatlabFunctions.h
//  CellScope
//
//  Created by Wayne Gerard on 12/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#ifndef CellScope_MatlabFunctions_h
#define CellScope_MatlabFunctions_h

/**
    A loose grouping of functions that correspond to functions in matlab.
    @author Wayne Gerard
 */

/**
    Repeats a value and puts it into a matrix
    @param value The value to be repeated
    @param sz The size of the matrix
 */
float[][] repmat(float value, size_t sz);

#endif
