//
//  STLPreviewViewController.h
//  StarLight
//
//  Created by Brian Olencki on 1/17/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLPreviewViewController : UIViewController
@property (nonatomic, retain, readonly) NSArray<UIImage*> *images;
@property (nonatomic, readonly) CGFloat duration;
- (instancetype)initWithImages:(NSArray<UIImage *> *)images animationDuration:(CGFloat)duration;
@end
