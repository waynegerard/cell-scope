//
//  Patch.mm
//  CellScope
//
//  Created by Wayne Gerard on 5/17/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Patch.h"

@implementation Patch

@synthesize patchSize = _patchSize, centroids = _centroids, sortedScores = _sortedScores;

- (NSMutableIndexSet*) findLowConfidencePatches
{
    float lowlim = 1e-6;
    NSMutableIndexSet* lowConfidencePatches = [NSMutableIndexSet indexSet];
    
    for (int i = 0; i < [self.sortedScores count]; i++) {
        float score = [[self.sortedScores objectAtIndex:i] floatValue];
        if (score <= lowlim) {
            [lowConfidencePatches addIndex:i];
        }
    }
    return lowConfidencePatches;
}

- (NSMutableIndexSet*) findSuppressedPatches
{
    //float maxDistance = pow((pow(self.orig.rows, 2.0) + pow(self.orig.cols, 2.0)), 0.5);
    
    // Setup rows and columns for next step
    NSMutableArray* centroidRows = [NSMutableArray array];
    NSMutableArray* centroidCols = [NSMutableArray array];
    for (int i = 0; i < [self.centroids count]; i++) {
        NSArray* centroid = [self.centroids objectAtIndex:i];
        int row = [[centroid objectAtIndex:0] intValue];
        int col = [[centroid objectAtIndex:1] intValue];
        [centroidRows addObject:[NSNumber numberWithInt:row]];
        [centroidCols addObject:[NSNumber numberWithInt:col]];
    }
    
    NSMutableIndexSet* suppressedPatches = [NSMutableIndexSet indexSet];
    for (int i = 0; i < [_sortedScores count]; i++) { // This should start from the highest-scoring patch
        NSArray* centroid = [self.centroids objectAtIndex:i];
        int row = [[centroid objectAtIndex:0] intValue];
        int col = [[centroid objectAtIndex:1] intValue];
        
        NSArray* rowCopy = [NSArray arrayWithArray:centroidRows];
        NSArray* colCopy = [NSArray arrayWithArray:centroidCols];
        NSMutableArray* distance = [NSMutableArray array];
        
        float minDistance = 1e99;
        int minDistanceIndex = -1;
        
        for (int j = 0; j < [rowCopy count]; j++) {
            int newRowVal = row - [[rowCopy objectAtIndex: j] intValue];
            int newColVal = col - [[colCopy objectAtIndex: j] intValue];
            
            newRowVal = pow(newRowVal, 2.0);
            newColVal = pow(newColVal, 2.0);
            
            double newVal = newRowVal + newColVal;
            newVal = pow(newVal, 0.5);
            
            if (newVal < minDistance && newVal != 0) {
                minDistance = newVal;
                minDistanceIndex = j;
            }
            
            
            [distance addObject:[NSNumber numberWithFloat:newVal]];
        }
        
        // Find the patch with the minimum distance (that isn't the current patch, where distance == 0)
        
        // See if it's too close. If it is, then suppress the patch
        float cutoff = 0.75 * self.patchSize; // non-max suppression parameter, "too close" distance
        if(minDistance <= cutoff) { // if too much overlap
            // Suppress this patch
            [suppressedPatches addIndex:i];
        }
    }
    return suppressedPatches;
}

@end
