//
//  Blobid.m
//  CellScope
//
//  Created by Wayne Gerard on 12/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "Blobid.h"

@implementation Blobid

/**
    Simple function that finds blobs in a grayscale image
 */
- (void) blobid {
    
    
    /*
     function imbw = blobid(orig,viewblobid)
     % USAGE: imbw = blobid(orig,viewblobid)
     
     
     %% Morphological opening
     [imthresh,imdf] = jcmorpho(orig,viewblobid);
     
     
     %% Combine xcorr and morpho outputs
     imbw = imbw_xcorr & imthresh;
     
     imbw = imclose(imbw,strel('square',3));
     
     save tmp.mat
     
     end
     
     function [imthresh,imdf] = jcmorpho(orig,viewblobid)
     imbigop=imopen(orig,strel('square',10));%strel('disk',10)
     imdf=orig-imbigop;
     imthresh=imdf>(mean(imdf(:)) + 3*std(imdf(:)));
     */
    
}

@end
