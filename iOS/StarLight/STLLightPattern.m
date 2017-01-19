//
//  STLLightPattern.m
//  StarLight
//
//  Created by Brian Olencki on 12/26/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLLightPattern.h"
#import "NS2DArray.h"
#import "NSString+Hex.h"

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
- (NSData *)dataPattern {
    return [self.absolutePattern hexData];
}
- (void)reloadPattern {
    strPattern = @"";

    if (!_delay || !_states || !_lights) {
        return;
    }
    
    [self addCommand:[NSString stringWithFormat:@"%u",_delay]];
    
    NSInteger frame = 0;
    for (NS2DArray *state in _states) {
        [state enumerateObjectsUsingBlock:^(id obj, NSIndexPath *indexPath, BOOL *stop) {
            NSInteger lightNumber = [[_lights objectAtIndexPath:indexPath] integerValue];
            if (lightNumber != -1 && [obj boolValue] == YES) {
                [self addCommand:[NSString stringWithFormat:@"%hi%@",(int16_t)lightNumber,[[self.colorForLightIndexWithFrame(lightNumber,frame) hexValue] stringByReplacingOccurrencesOfString:@"#" withString:@""]]];
            }
        }];
        [self addCommand:@"FF"];
        frame++;
    }
}

#pragma mark - Handling
- (void)addCommand:(NSString*)command {
    strPattern = [NSString stringWithFormat:@"%@\n%@",strPattern,command];
}
@end
