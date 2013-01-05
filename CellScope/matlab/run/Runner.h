//
//  Runner.h
//  CellScope
//
//  Created by Wayne Gerard on 1/5/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    The runner class handles three things:
    1) Prompting the user to choose which images should be run
    2) For each image, passing that image off to a new ImageRunner instnace
    3) Timing how long the entire process takes
 
    @author Wayne Gerard
 */
@interface Runner : NSObject

/**
    Main runner function. Prompts the user to choose a series of images, and then
    Instantiates an ImageRunner for each image.
    @param hog Whether to do HoG features or not
    @param patchSz The patch size
 */
- (void) runWithHogFeatures:(BOOL) hog wthPatchSize:(int) patchSz;

@end
