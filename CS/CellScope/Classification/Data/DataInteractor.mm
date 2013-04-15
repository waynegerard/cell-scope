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

+ (cv::Mat) loadCSVWithPath: (NSString*) path {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:path ofType:@"csv"];
    NSString* fullBuffer = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray* csvArray = [fullBuffer componentsSeparatedByString:@"\r"]; // Line endings
    int row = 0;
    int col = 0;
    
    int maxRows = [csvArray count];
    NSString* firstRow = [csvArray objectAtIndex:0];
    int maxCols = [[firstRow componentsSeparatedByString:@","] count];
    cv::Mat csvMat(maxRows, maxCols, CV_32F);
    
    for (int i = 0; i < [csvArray count]; i++) {
        NSString* items = [csvArray objectAtIndex:i];
        NSArray* splitRow = [items componentsSeparatedByString:@","];
        col = 0;
        for (int j = 0; j < [splitRow count]; j++) {
            NSString* item = [splitRow objectAtIndex:j];
            CSLog(@"Trying to add item %@", item);
            csvMat.at<float>(row, col) = [item floatValue];
            CSLog(@"Added item: %@", item);
            col++;
        }
        row++;
    }
    
    return csvMat;
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
