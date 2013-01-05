//
//  Runner.m
//  CellScope
//
//  Created by Wayne Gerard on 1/5/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Runner.h"
#import "ImageRunner.h"
#import "Globals.h"

@implementation Runner

- (void) runWithHogFeatures:(BOOL) hogFeatures wthPatchSize:(int) patchSz {
    
    /////////////////////////////////
    // Handle incorrect parameters //
    /////////////////////////////////
    int patchSize  = (patchSize % 2 != 0) ? 24 : patchSz;
    
    ////////////////////
    // Load the model //
    ////////////////////
    if (hogFeatures) {
        // TODO: Load the model without HoG features
    } else {
        // TODO: Load model with HoG features
    }
    
    ////////////
    // Timing //
    ////////////
    
    // Start timing
    // TODO: Timing
    
    ///////////////////////
    // Choose the images //
    ///////////////////////
    
    // TODO: Let user choose images
    NSMutableArray* images = [NSMutableArray arrayWithCapacity:1];
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
        
        [imgRunner runWithImage:ui_img];
    }
    
    // TODO: Stop timing
}


@end
