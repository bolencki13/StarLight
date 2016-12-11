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
- (void)configurationViewController:(STLAdvancedViewController*)viewController didFinishWithMatrix:(NS2DArray*)matrix;
@end

@interface STLAdvancedViewController : UIViewController
@property (nonatomic, readonly) NS2DArray *matrix;
- (instancetype)initWithMatrix:(NS2DArray*)matrix;
@end
