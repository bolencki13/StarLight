//
//  STLConfigurationViewController.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STLConfigurationViewController, NS2DArray, STLHub, STLLightPattern;
@protocol STLConfigurationViewControllerDelegate <NSObject>
- (void)configurationViewController:(STLConfigurationViewController*)viewController didFinishWithImage:(UIImage*)image states:(NS2DArray*)states;
@end

@interface STLConfigurationViewController : UIViewController
@property (nonatomic, retain, readonly) STLHub *hub;
@property (nonatomic, retain) id<STLConfigurationViewControllerDelegate> delegate;
+ (STLLightPattern*)lightPatternFromStates:(NS2DArray*)states;
- (instancetype)initWithHub:(STLHub*)hub withCurrentImage:(UIImage*)image withStates:(NS2DArray*)states;
@end
