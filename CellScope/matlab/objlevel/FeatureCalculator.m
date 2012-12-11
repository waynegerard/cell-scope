//
//  FeatureCalculator.m
//  CellScope
//
//  Created by Wayne Gerard on 12/10/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "FeatureCalculator.h"

@implementation FeatureCalculator

/**
    Takes the patches and calculates various Hu moments, geometric, and photometric features
    @param blobs 
 */
- (void) calculateFeaturesWithBlobs: (NSObject*) blobs withPatchSize:(int) patchSize doHoG:(BOOL) HoG {
    for (int i = 0; i < blobs.numObjects; i++) {
        patch = blobs.stats(n).patch;
        
        // Calculate Hu moments
        blobs.stats(n).phi = huMoment(patch);
        
        // Geometric and photometric features
        blobs.stats(n).geom = geom(patch, blobs.stats(n).binpatch);
        
        if (HoG) {
            blobs.stats(n).hog = getHoGHist(blobs.stats(n).gradpatch);
        }
    }
    
    // Visually check binarization of patches
    BOOL showGrayPatches = NO;
    BOOL showBinPatches = NO;
    int sz = patchSize;
    
    if (showGrayPatches) {
        int j = 0;
        NSMutableArray* allPatches = [NSMutableArray array];
        int numPatchesPerCol = 10;
        int extra = numPatchesPerCol - (blobs.numObjects %% numPatchesPerCol);
        for (int n = 0; n < blobs.numObjects + extra; n++) {
            j++;
            if (n > blobs.numObjects) {
                allPatches[1][j] = makeZeroMatrix(sz, sz);
            } else {
                patch = blobs.stats(n).patch;
                if patch.isEmpty() {
                    allPatches[1][j] = makeZeroMatrix(sz, sz);
                } else {
                    allPatches[1][j] = patch;
                }
            }
        }
        allPatches = reshape(allPatches, numPatchesPerCol, []);
        imAllPatches = cell2mat(allPatches);
        // TODO: do we need this?
        // figure imshow(imallpatches)l title (grayscale patches in calcfeats)        
    }
    
    if (showBinPatches) {
        int j = 0;
        NSMutableArray* allPatches = [NSMutableArray array];
        int numPatchesPerCol = 10;
        int extra = numPatchesPerCol - (blobs.numObjects %% numPatchesPerCol);
        for (int n = 0; n < blobs.numObjects + extra; n++) {
            j++;
            if n > blobs.numObjects {
                allPatches[1][j] = logical(ones(sz, sz)); // TODO: Figure out a C++ way to do this
            }
            else {
                patch = blobs.stats(n).binpatch;
                if isEmpty(patch) {
                    allPatches[1][j] = logical(ones(sz, sz)); // TODO: Figure out a C++ way to do this
                } else {
                    allPatches[1][j] = patch;
                }
            }
        }
        
        allPatches = reshape(allPatches, numPatchesPerCol, []);
        imAllPatches = cell2mat(allPatches);
        
        // TODO: do we need this?
        // figure; imshow(imallpatches); title('Bin patches in calcfeats');
    }
    
}

@end
