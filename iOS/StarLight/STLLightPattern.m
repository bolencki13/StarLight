//
//  STLLightPattern.m
//  StarLight
//
//  Created by Brian Olencki on 12/26/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLLightPattern.h"
#import "NS2DArray.h"

#import <Chameleon.h>

@interface STLLightPattern () {
    NSString *strPattern;
}
@end

@implementation STLLightPattern
+ (STLLightPattern *)pattern {
    return [self new];
}
- (instancetype)init {
    self = [super init];
    if (self) {
        strPattern = @"";
    }
    return self;
}

#pragma mark - Public
- (NSString*)absolutePattern {
    return strPattern;
}
- (void)reloadPattern {
    strPattern = @"";

    if (!_delay || !_states || !_lights || self.colorForLightIndexWithFrame) {
        return;
    }
    
    [self addCommand:[NSString stringWithFormat:@"%f",_delay]];
    [self addCommand:@"\n"];
    
    NSInteger frame = 0;
    for (NS2DArray *state in _states) {
        [state enumerateObjectsUsingBlock:^(id obj, NSIndexPath *indexPath, BOOL *stop) {
            NSInteger lightNumber = [[_lights objectAtIndexPath:indexPath] integerValue];
            [NSString stringWithFormat:@"%li%@",(long)lightNumber,[self.colorForLightIndexWithFrame(lightNumber,frame) hexValue]];
        }];
        [self addCommand:@"\n"];
        frame++;
    }
}

#pragma mark - Handling
- (void)addCommand:(NSString*)command {
    strPattern = [NSString stringWithFormat:@"%@\n%@",strPattern,command];
}
@end
