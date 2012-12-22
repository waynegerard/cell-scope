//
//  ImageTools.m
//  CellScope
//
//  Created by Wayne Gerard on 12/20/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "ImageTools.h"

@implementation ImageTools

/** Calculates the euclidean distance between two points
    @param p1 The first point
    @param p2 The second point
    @return Returns the Euclidean distance between the two points
 */
- (float) euclideanDistance(CGPoint p1, CGPoint p2) {
    float dx = p1.x - p2.x;
    float dy = p1.y - p2.y;
    return pow(pow(dx, 2) + pow(dy, 2), 0.5);
}

/** Calculates the central p,q moment of a grayscale input image
    @param im The grayscale image
    @param p  The p factor
    @param q  The q factor
    @param xc The xc constant
    @param yc The yc constant
 */
- (float) momentpq(im,p,q,xc,yc) {
    xc_mat = repmat(xc, size(im));
    yc_mat = repmat(yc, size(im));

    [ygrid, xgrid] = meshgrid([1:size(im,2)],[1:size(im,1)]);

    newmat = ((xgrid-xc_mat).^p).*((ygrid-yc_mat).^q).*im;
    mu = sum(newmat(:));
}


@end
