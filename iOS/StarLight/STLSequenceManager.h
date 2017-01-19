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

@class STLLight, STLHub;
@interface STLSequenceManager : NSObject
+ (STLSequenceManager*)sharedManager;
@property (nonatomic, retain) STLHub *hub;
- (void)setLightAtPosition:(NSInteger)position on:(BOOL)on;
- (void)setLightAtPosition:(NSInteger)position toColor:(UIColor*)color;
- (void)uploadPattern:(STLLightPattern*)pattern;
@end
