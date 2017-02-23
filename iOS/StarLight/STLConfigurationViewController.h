//
//  STLConfigurationViewController.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STLConfigurationViewController, STLHub, STLLightPattern;
@protocol STLConfigurationViewControllerDelegate <NSObject>
- (void)configurationViewController:(STLConfigurationViewController*)viewController withLightPattern:(STLLightPattern*)pattern;
@end

@class STLLightPattern;
@interface STLConfigurationViewController : UIViewController
@property (nonatomic, retain, readonly) STLHub *hub;
@property (nonatomic, retain, readonly) STLLightPattern *pattern;
@property (nonatomic, retain) id<STLConfigurationViewControllerDelegate> delegate;
- (instancetype)initWithPattern:(STLLightPattern*)pattern;
@end
