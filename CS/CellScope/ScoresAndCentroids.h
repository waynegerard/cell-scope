//
//  ScoresAndCentroids.h
//  CellScope
//
//  Created by Wayne Gerard on 7/23/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ScoresAndCentroids : NSManagedObject

@property (nonatomic, retain) NSString* image_name;
@property (nonatomic, retain) NSData* scores;
@property (nonatomic, retain) NSData* centroids;

@end
