//
//  Runner.m
//  CellScope
//
//  Created by Wayne Gerard on 1/5/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Runner.h"

#import "DataInteractor.h"
#import "ImageRunner.h"
#import "Globals.h"
#import "svm.h"

@implementation Runner

- (void) runWithHogFeatures:(BOOL) hogFeatures wthPatchSize:(int) patchSz {
    
    /////////////////////////////////
    // Handle incorrect parameters //
    /////////////////////////////////
    int patchSize  = (patchSz % 2 != 0) ? 24 : patchSz;
    
    ////////////////////
    // Load the model //
    ////////////////////
    svm_model* model;
    if (hogFeatures) {
        // TODO: Load the model without HoG features
    } else {
        model = [DataInteractor loadSVMModelWithPathName:@"model_without"];
    }
    
    NSDate *start = [NSDate date];
    
    ///////////////////////
    // Choose the images //
    ///////////////////////
    
    // TODO: Let user choose images
    NSMutableArray* images = [NSMutableArray arrayWithCapacity:1];
    UIImage* img = [UIImage imageNamed:@"1350_Clay_Fluor_Yes.png"];
    [images addObject:img];
    int count = [images count];
    
    ////////////////////
    // Run the images //
    ////////////////////
    
    for (int i = 0; i < count; i++) {
        CSLog(@"Processing image %d of %d", i, count);
        UIImage* ui_img = [images objectAtIndex:i];
        
        ImageRunner* imgRunner = [[ImageRunner alloc] init];
        [imgRunner setPatchSize:patchSize];
        [imgRunner setHogFeatures:hogFeatures];
        [imgRunner setModel:model];
        [imgRunner runWithImage:ui_img];
    }
    
    NSDate *end = [NSDate date];
    NSTimeInterval executionTime = [end timeIntervalSinceDate:start];
    CSLog(@"Execution Time: %f", executionTime);
    
}


@end
