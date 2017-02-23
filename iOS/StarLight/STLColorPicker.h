//
//  NFLColorPicker.h
//  NotificationLights
//
//  Created by Brian Olencki on 2/3/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLColorPicker : UIView
@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, copy) void (^tappedCenter)();
@property (nonatomic, retain) UIView *viewCenter;
- (UIImage*)imageFromColor:(UIColor*)color;
- (NSString*)hexFromUIColor:(UIColor*)color;
@end
