//
//  UIImage+Size.m
//  StarLight
//
//  Created by Brian Olencki on 2/22/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import "UIImage+Size.h"

@implementation UIImage (Size)
- (UIImage *)resize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
