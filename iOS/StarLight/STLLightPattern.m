//
//  STLLightPattern.m
//  StarLight
//
//  Created by Brian Olencki on 12/26/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLLightPattern.h"
#import "STLLightFrame.h"

#import <Chameleon.h>

@interface STLLightPattern () {
    NSString *strPattern;
}
@end

@implementation STLLightPattern
+ (NSString*)frameIdentifier {
    return @"$$";
}
+ (STLLightPattern*)patternWithFrames:(NSArray<STLLightFrame*>*)frames {
    STLLightPattern *pattern = [self new];
    pattern.frames = frames;
    
    return pattern;
}
- (instancetype)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        self.delay = [[json objectForKey:@"delay"] integerValue];
        
        NSMutableArray *aryFrames = [NSMutableArray new];
        for (NSDictionary *frame in [json objectForKey:@"frames"]) {
            [aryFrames addObject:[[STLLightFrame alloc] initWithJSON:frame]];
        }
        self.frames = aryFrames;
    }
    return self;
}

#pragma mark - Public
- (NSString*)absolutePattern {
    strPattern = [NSString stringWithFormat:@"%ld%@",(long)self.delay,[STLLightPattern frameIdentifier]];

    for (STLLightFrame *frame in self.frames) {
        strPattern = [NSString stringWithFormat:@"%@%@%@",strPattern,frame.absoluteFrame,[STLLightPattern frameIdentifier]];
    }
    
    return strPattern;
}
- (NSData *)dataPattern {
    return [self.absolutePattern dataUsingEncoding:NSUTF8StringEncoding];
}
- (STLHub *)hub {
    return [self.frames objectAtIndex:0].hub;
}
- (NSDictionary *)JSON {
    NSMutableDictionary *dictJSON = [NSMutableDictionary new];
    
    NSMutableArray *aryFrames = [NSMutableArray new];
    for (STLLightFrame *frame in self.frames) {
        [aryFrames addObject:[frame JSON]];
    }
    [dictJSON setObject:aryFrames forKey:@"frames"];
    [dictJSON setObject:[NSNumber numberWithInteger:self.delay] forKey:@"delay"];
    
    return dictJSON;
}
@end
