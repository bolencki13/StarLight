//
//  AppDelegate.h
//  StarLight
//
//  Created by Brian Olencki on 12/6/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)executeOnQueue:(dispatch_queue_t)queue withTimeConstraint:(NSTimeInterval)time withName:(NSString*)name block:(void(^)())block;
@end

