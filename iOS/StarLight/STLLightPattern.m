//
//  STLLightPattern.m
//  StarLight
//
//  Created by Brian Olencki on 12/26/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLLightPattern.h"
#import "STLHub.h"

#import <UIKit/UIColor.h>
#import <Chameleon.h>

@interface STLLightPattern () {
    NSString *pattern;
}
@end

@implementation STLLightPattern
+ (STLLightPattern*)patternForHub:(STLHub *)hub {
    return [[STLLightPattern alloc] initWithHub:hub];
}
- (instancetype)initWithHub:(STLHub*)hub {
    self = [super init];
    if (self) {
        _hub = hub;
        pattern = [NSString stringWithFormat:@"%@\n",_hub.identifer];
    }
    return self;
}
- (NSString*)visualPattern {
    return pattern;
}

#pragma mark - Actions
- (void)addLightAtPosition:(NSInteger)position withColor:(UIColor *)color {
    NSString *hexColor = @"000000";
    if (![color isEqual:[UIColor clearColor]]) {
        hexColor = [color hexValue];
    }
    [pattern stringByAppendingString:[NSString stringWithFormat:@"\n%02lx%@",(long)position,hexColor]];
}
- (void)addDelayForTime:(NSTimeInterval)time {
    [pattern stringByAppendingString:[NSString stringWithFormat:@"\nsleep(%f)",time]];
}
- (void)removeLastItem {
    NSMutableArray *aryTemp = [[pattern componentsSeparatedByString:@"\n"] mutableCopy];
    [aryTemp removeLastObject];
    pattern = [aryTemp componentsJoinedByString:@"\n"];
}
@end
