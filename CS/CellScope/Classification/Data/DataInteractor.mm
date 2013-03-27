//
//  DataInteractor.m
//  CellScope
//
//  Created by Wayne Gerard on 3/25/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "DataInteractor.h"
#import "CSAppDelegate.h"

@implementation DataInteractor

+ (NSMutableArray*) loadCSVWithPath: (NSString*) path {
    NSMutableArray* array = [NSMutableArray array];
    
    NSString* fullBuffer = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray* csvArray = [fullBuffer componentsSeparatedByString:@"\r"]; // Line endings
    
    for (NSString* row in csvArray) { // Split into commas
        NSArray* splitRow = [row componentsSeparatedByString:@","];
        [array addObject:splitRow];
    }
    
    return array;
}

+ (void) storeScores: (NSMutableArray*) scores withCentroids:(NSMutableArray*) centroids{
    CSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject* newScoresAndCentroids;
    
    newScoresAndCentroids = [NSEntityDescription
                            insertNewObjectForEntityForName:@"ScoresAndCentroids"
                             inManagedObjectContext:context];
    
    NSData* scoresData = [NSKeyedArchiver archivedDataWithRootObject:scores];
    NSData* centroidsData = [NSKeyedArchiver archivedDataWithRootObject:centroids];

    [newScoresAndCentroids setValue:scoresData forKey:@"scores"];
    [newScoresAndCentroids setValue:centroidsData forKey:@"centroids"];
    
    NSError *error;
    [context save:&error];
    CSLog(@"Saving down to core data, error: %@", error);
}

@end
