//
//  MatlabFunctions.c
//  CellScope
//
//  Created by Wayne Gerard on 12/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#include <stdio.h>

#define NELEMS(x) (sizeof(x) / sizeof(x[0]))

float[][] repMat(float value, size_t sz) {
    float[][] newMatrix = float[sz.height][sz.width];
    for (int i = 0; i < sz.height; i++) {
        for (int j = 0; j < sz.width; j++) {
            newMatrix[i][j] = value;
        }
    }
    return newMatrix;
}

size_t getMeshSize(float[] xgv, float[] ygv) {
    int len_xgv = NELEMS(xgv);
    int len_ygv = NELEMS(ygv);
    size_t sz;
}

void meshgrid(float[] xgv, float[] ygv, float[][] & X, float[][] & Y) {
    int len_xgv, len_ygv;
    
    
    X = 
}

