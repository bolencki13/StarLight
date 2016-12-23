//
//  STLCalibrationViewController.h
//  StarLight
//
//  Created by Brian Olencki on 12/8/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPeripheral;
@interface STLCalibrationViewController : UIViewController
@property (nonatomic, readonly) BOOL calibrating;
@property (nonatomic, readonly) BOOL positioning;
@property (nonatomic, retain, readonly) CBPeripheral *peripheral;
- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral;
@end
