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
- (void)configurationViewController:(STLConfigurationViewController*)viewController states:(NSArray<NS2DArray*>*)states;
@end

@class STLHub;
@interface STLConfigurationViewController : UIViewController
@property (nonatomic, retain, readonly) STLHub *hub;
@property (nonatomic, retain, readonly) NSArray<NS2DArray*> *states;
@property (nonatomic, retain) id<STLConfigurationViewControllerDelegate> delegate;
- (instancetype)initWithHub:(STLHub*)hub withStates:(NSArray<NS2DArray *>*)states;
@end
