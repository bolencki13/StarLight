//
//  STLViewController.h
//  StarLight
//
//  Created by Brian Olencki on 12/13/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (UIImage)
+ (nonnull instancetype)alertControllerWithTitle:(nullable NSString *)title image:(nullable UIImage *)image preferredStyle:(UIAlertControllerStyle)preferredStyle;
@end
