//
//  HuMomentCalculator.m
//  CellScope
//
//  Created by Wayne Gerard on 12/13/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "HuMomentCalculator.h"

@implementation HuMomentCalculator

/**
 Takes a grayscale image and returns Hu moments, as defined by Gonzalez
 and Woods (Digital Image Processing, 3rd ed.), p. 840-841
 @param im The grayscale image
 @return Returns the hu moments for the grayscale
 */
- (NSMutableArray*) huMoment(im) {
    
    /*
     im = im2double(im); % convert to double for calculations
    */
    
    /*
     % Centroid coordinates
     [colgd,rowgd] = meshgrid(1:size(im,2),1:size(im,1));
     m00 = sum(sum(im));
     m10 = sum(sum(rowgd.*im));
     m01 = sum(sum(colgd.*im));
     xc = m10/m00;
     yc = m01/m00;
    */
    
    /*
     % Calculate central (mu) and normalized central (eta) moments
     for p = 0:4
        for q = 0:4
            %if(~mod(p+q,2))
            mu(p+1,q+1) = momentpq(im,p,q,xc,yc); % CAREFUL!  mu_00 is stored in mu(1,1)
            eta(p+1,q+1)= mu(p+1,q+1)/(mu(1,1)^(1+(p+q)/2));
            %end
        end
     end
    */
    
    /*
     % NOTE: all indices of mu and eta are incremented to avoid zero indices.
     % E.g., mu(1,1) is actually mu_00
     
     % phi(1) = phi_1
     phi(1) = eta(3,1)+eta(1,3);
     phi(2) = (eta(3,1)-eta(1,3))^2+4*eta(2,2)^2;
     phi(3) = (eta(4,1)-3*eta(2,3))^2+(3*eta(3,2)-eta(1,4))^2;
     phi(4) = (eta(4,1)+eta(2,3))^2+(eta(3,2)+eta(1,4))^2;
     phi(5) = (eta(4,1)-3*eta(2,3))*(eta(4,1)+eta(2,3))*((eta(4,1)+eta(2,3))^2-3*(eta(3,2)+eta(1,4))^2)+(3*eta(3,2)-eta(1,4))*(eta(3,2)+eta(1,4))*(3*(eta(4,1)+eta(2,3))^2-(eta(3,2)+eta(1,4))^2);
     phi(6) = (eta(3,1)-eta(1,3))*((eta(4,1)+eta(2,3))^2-(eta(3,2)+eta(1,4))^2)+4*eta(2,2)*(eta(4,1)+eta(2,3))*(eta(3,2)+eta(1,4));
     phi(7) = (3*eta(3,2)-eta(1,4))*(eta(4,1)+eta(1,2))*((eta(4,1)+eta(2,3))^2-3*(eta(3,2)+eta(1,4))^2)+(3*eta(2,3)-eta(4,1))*(eta(3,2)+eta(1,4))*(3*(eta(4,1)+eta(2,3))^2-(eta(3,2)+eta(1,4))^2);
     phi(8) = eta(5,1)-2*eta(3,3)+eta(1,5); % This actually phi_11 in Forero's paper
     */
    
}


@end
