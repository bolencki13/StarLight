//
//  STLLightPattern.h
//  StarLight
//
//  Created by Brian Olencki on 12/26/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIColor;
@interface STLLightPattern : NSObject
@property (nonatomic, retain, readonly) NSString *visualPattern;
+ (STLLightPattern*)pattern;
- (void)addLightAtPosition:(NSInteger)position withColor:(UIColor*)color;
- (void)addDelayForTime:(NSTimeInterval)time;
- (void)removeLastItem;
@end
