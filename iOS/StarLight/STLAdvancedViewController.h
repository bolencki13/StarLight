//
//  STLAdvancedViewController.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STLAdvancedViewController, NS2DArray;
@protocol STLAdvancedViewControllerDelegate <NSObject>
- (void)configurationViewController:(STLAdvancedViewController*)viewController didFinishWithStates:(NS2DArray*)states;
@end

@interface STLAdvancedViewController : UIViewController
@property (nonatomic, retain, readonly) NS2DArray *matrix;
@property (nonatomic, retain, readonly) NS2DArray *lightState;
@property (nonatomic, retain) id<STLAdvancedViewControllerDelegate> delegate;
- (instancetype)initWithLightsMatrix:(NS2DArray*)matrix withLightState:(NS2DArray*)state; // 'matrix' is the light configuration; 'state' is the light state in the configuration; error will occure if size is not the same
@end
