//
//  DataInteractor.h
//  CellScope
//
//  Created by Wayne Gerard on 3/25/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

@interface DataInteractor : NSObject

/**
    Loads a CSV into an NSMutableArray (an array of arrays), and returns it.
 */
+ (NSMutableArray*) loadCSVWithPath: (NSString*) path;

/**
    Stores scores and centroids down to core data.
    @param scores    Corresponding scores (likelihood of being bacilli)
    @param centroids Array of centroids, sorted by descending patch score. 
                     Each row contains (row,col) indices.
 */
+ (void) storeScores: (NSMutableArray*) scores withCentroids:(NSMutableArray*) centroids;

@end
