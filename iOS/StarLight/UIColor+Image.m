//
//  UIColor+Image.m
//  StarLight
//
//  Created by Brian Olencki on 2/22/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import "UIColor+Image.h"

@implementation UIColor (Image)
- (UIImage *)image {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
