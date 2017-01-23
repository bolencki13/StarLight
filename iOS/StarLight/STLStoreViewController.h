//
//  STLStoreViewController.h
//  StarLight
//
//  Created by Brian Olencki on 1/23/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STLHub;
@interface STLStoreViewController : UIViewController
@property (nonatomic, retain, readonly) STLHub *hub;
- (instancetype)initWithHub:(STLHub*)hub;
@end
