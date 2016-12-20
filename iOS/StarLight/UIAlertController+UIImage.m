//
//  STLViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/13/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "UIAlertController+UIImage.h"

@implementation UIAlertController (UIImage)
+ (instancetype)alertControllerWithTitle:(NSString *)title image:(UIImage *)image preferredStyle:(UIAlertControllerStyle)preferredStyle {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"\n\n\n\n\n\n" preferredStyle:preferredStyle];
    
    UIImageView *imgViewAlert = [[UIImageView alloc] initWithImage:image];
    [imgViewAlert setFrame:CGRectMake(35, 50, (CGRectGetWidth(alert.view.frame)-20)/2, 100)];
    [imgViewAlert setContentMode:UIViewContentModeScaleAspectFit];
    [alert.view addSubview:imgViewAlert];
        
    return alert;
}
@end
