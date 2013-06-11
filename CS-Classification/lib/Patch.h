//
//  Patch.h
//  CellScope
//
//  Created by Wayne Gerard on 5/17/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

@interface Patch : NSObject { 
    NSMutableArray* _centroids;
    NSMutableArray* _sortedScores;
    int _patchSize;
}

@property (nonatomic, retain) NSMutableArray* centroids;
@property (nonatomic, retain) NSMutableArray* sortedScores;
@property (nonatomic, assign) int patchSize;

/**
 Drops low confidence patches, defined as patches where the score is less
 than some designated threshold
 
 @return Returns a list of indices of patches that should be dropped
 */
- (NSMutableIndexSet*) findLowConfidencePatches;

/**
 Locates patches that should be suppressed, for being too close to each other
 @return Returns the indices for all patches that should be suppressed
 */
- (NSMutableIndexSet*) findSuppressedPatches;


@end
