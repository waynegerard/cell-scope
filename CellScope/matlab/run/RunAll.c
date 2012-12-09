//
//  RunAll.c
//  CellScope
//
//  Created by Wayne Gerard on 11/30/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//


/**
 Run all scripts to identify and save objects/features for
 training.  Run only once for a given data set.
 */
void runall() {

    // Save objects from positive images with tags
    savePosObjects();
    savePosFeats();
    
    // Save objects from positive images with tags BUT IGNORING THEM
    savePosObjsIgnoreTag();
    savePosFeatsIgnoreTag();
    
    // Save objects from positive images WITHOUT tags
    savePosObjsWithoutTag();
    savePosFeatsWithoutTag();

    // Save objects from negative images
    saveNegObjs();
    saveNegFeats();
    
}

#include <stdio.h>
