//
//  STLCalibrationViewController.h
//  StarLight
//
//  Created by Brian Olencki on 12/8/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSNotificationName kSTLCalibrationDidFinish;

@class STLCalibrationViewController, CBPeripheral, STLHub;
@protocol STLCalibrationViewControllerDelegate <NSObject>
- (void)calibrationdidFinish:(STLCalibrationViewController*)viewController withHub:(STLHub*)hub;
@end

@interface STLCalibrationViewController : UIViewController
@property (nonatomic, readonly) BOOL calibrating;
@property (nonatomic, retain, readonly) CBPeripheral *peripheral;
@property (nonatomic, retain) id<STLCalibrationViewControllerDelegate> delgate;
- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral;
@end
