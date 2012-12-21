//
//  ImageTools.m
//  CellScope
//
//  Created by Wayne Gerard on 12/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "ImageTools.h"

@implementation ImageTools

- (float) euclideanDistance(CGPoint p1, CGPoint p2) {
    float dx = p1.x - p2.x;
    float dy = p1.y - p2.y;
    return pow(pow(dx, 2) + pow(dy, 2), 0.5);
    
}

@end
