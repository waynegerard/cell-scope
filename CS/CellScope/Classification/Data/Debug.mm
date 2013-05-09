//
//  Debug.m
//  CellScope
//
//  Created by Wayne Gerard on 2/18/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "Debug.h"

@implementation Debug

+ (void) printMatrix:(cv::Mat) mat {

    int rows = mat.rows;
    int cols = mat.cols;
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            float val = mat.at<float>(i, j);
            NSLog(@"Value at %d, %d: %f", i, j, val);
        }
    }
}

+ (void) printMatrixToFile:(cv::Mat) mat withRows:(int) rows withCols:(int) cols withName:(NSString*) name {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, name];
    
    [@"" writeToFile:fileName atomically:YES encoding:NSUnicodeStringEncoding error:nil];
    
    CSLog(@"Loading contents");
    for (int i = 0; i < rows; i++) {
        NSString* newText = @"";
        for (int j = 0; j < cols; j++) {
            if (mat.type() == CV_8UC1) {
                int val = (int) mat.at<unsigned char>(i, j);
                newText = [NSString stringWithFormat:@"%@%d,", newText, val];
            } else if (mat.type() == CV_32F) {
                float val = (float) mat.at<float>(i, j);
                newText = [NSString stringWithFormat:@"%@%f,", newText, val];
            }
        }
        NSError* err;
        NSString* contents = [NSString stringWithContentsOfFile:fileName encoding:NSUnicodeStringEncoding error:&err];
        contents = [contents stringByAppendingString:newText];
        [contents writeToFile:fileName atomically:YES encoding: NSUnicodeStringEncoding error:&err];

    }
        
}

+ (void) printArrayToFile:(NSMutableArray*) arr withName:(NSString*) name{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, name];
    
    [@"" writeToFile:fileName atomically:YES encoding:NSUnicodeStringEncoding error:nil];
    
    CSLog(@"Loading contents");
    for (int i = 0; i < [arr count]; i++) {
        NSValue* val = (NSValue*) [arr objectAtIndex:i];
        CGPoint pt = [val CGPointValue];
        NSString* newText = [NSString stringWithFormat:@"%f,%f ", pt.x, pt.y];
        NSError* err;
        NSString* contents = [NSString stringWithContentsOfFile:fileName encoding:NSUnicodeStringEncoding error:&err];
        contents = [contents stringByAppendingString:newText];
        [contents writeToFile:fileName atomically:YES encoding: NSUnicodeStringEncoding error:&err];
        
    }

}


@end
