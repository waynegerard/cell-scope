//
//  Runner.m
//  CellScope
//
//  Created by Wayne Gerard on 1/5/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#include "Classifier.h"
#import "Runner.h"
#import "ClassifierGlobals.h"
#import "ScoresAndCentroids.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation Runner

@synthesize managedObjectContext;

- (cv::Mat)cvMatWithImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat;
    
    if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB) { // 3 channels
        cvMat = cv::Mat(rows, cols, CV_8UC3);
    } else if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome) { // 1 channel
        cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    } 
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (void)viewDidAppear:(BOOL)animated {
    [self run];
}

- (char*) getFSRepresentation: (CFStringRef) name {
    CFURLRef url = CFBundleCopyResourceURL(CFBundleGetMainBundle(), name, CFSTR("txt"), NULL);
    UInt8* path = new UInt8[1024];
    CFURLGetFileSystemRepresentation(url, TRUE, path, sizeof(path));
    return (char*)path;
}

- (void) runWithImage: (UIImage*) img {
    char* model_path = [self getFSRepresentation:CFSTR("model_out")];
    char* max_path = [self getFSRepresentation:CFSTR("train_max")];
    char* min_path = [self getFSRepresentation:CFSTR("train_min")];

    
    NSDate *start = [NSDate date];
    NSLog(@"Processing image");
    cv::Mat converted_img = [self cvMatWithImage:img];
    cv::Mat results = Classifier::runWithImage(converted_img, (char*) model_path, (char*)max_path, (char*)min_path);
    NSLog(@"Possible TB candidates: %i", results.rows);
    NSDate *end = [NSDate date];
    NSTimeInterval executionTime = [end timeIntervalSinceDate:start];
    NSLog(@"Execution Time: %f", executionTime);
    
    // Save to Core Data
    if (SAVE_TO_CORE_DATA) {
        ScoresAndCentroids* imageData = (ScoresAndCentroids *)[NSEntityDescription insertNewObjectForEntityForName:@"ScoresAndCentroids" inManagedObjectContext:self.managedObjectContext];
    
        NSMutableArray* scores = [NSMutableArray array];
        NSMutableArray* centroids = [NSMutableArray array];
    
        for (int i = 0; i < results.rows; i++) {
            for (int j = 0; j < results.cols; j++) {
                float val = results.at<float>(i, j);
                NSNumber* numberVal = [NSNumber numberWithFloat: val];
                if (j == 0) {
                    [scores addObject: numberVal];
                } else {
                    [centroids addObject: numberVal];
                }
            }
        }
    
        imageData.scores = [NSKeyedArchiver archivedDataWithRootObject:scores];
        imageData.centroids = [NSKeyedArchiver archivedDataWithRootObject:centroids];
        imageData.image_name = [[NSDate date] description];
    
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to add new picture with error: %@", [error domain]);
        }
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [Picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [Picker dismissModalViewControllerAnimated:YES];
    [self runWithImage:image];
}

- (void) run {
    
    ///////////////////////
    // Choose the images //
    ///////////////////////
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:picker animated:YES];
    
}


@end
