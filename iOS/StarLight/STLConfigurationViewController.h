//
//  STLConfigurationViewController.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STLConfigurationViewController, NS2DArray;
@protocol STLConfigurationViewControllerDelegate <NSObject>
- (void)configurationViewController:(STLConfigurationViewController*)viewController didFinishWithImage:(UIImage*)image;
@end

@interface STLConfigurationViewController : UIViewController
@property (nonatomic, retain, readonly) id hub;
@property (nonatomic, retain) id<STLConfigurationViewControllerDelegate> delegate;
+ (BOOL)convertImage:(UIImage*)image toLightState:(NS2DArray*)matrix;
- (instancetype)initWithHub:(id)hub withCurrentImage:(UIImage*)image;
@end
