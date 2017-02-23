//
//  STLSequenceManager.h
//  StarLight
//
//  Created by Brian Olencki on 12/22/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>
#import "STLLightPattern.h"

#define DELAY_BLE (0.1)

@class STLLight, STLHub;
@interface STLSequenceManager : NSObject
@property (nonatomic, readonly) BOOL running;
@property (nonatomic, retain) STLHub *hub;
+ (STLSequenceManager*)sharedManager;
- (void)setLightAtPosition:(NSInteger)position on:(BOOL)on;
- (void)setLightAtPosition:(NSInteger)position toColor:(UIColor*)color;
- (void)uploadToHub:(STLHub*)hub;
@end
