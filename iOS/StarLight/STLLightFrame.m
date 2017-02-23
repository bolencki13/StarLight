//
//  STLLightFrame.m
//  StarLight
//
//  Created by Brian Olencki on 2/22/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import "STLLightFrame.h"
#import "STLHub.h"
#import "STLLight.h"
#import "STLDataManager.h"

#import <Chameleon.h>

@interface STLLightFrame () {
    NSString *strFrame;
}

@end

@implementation STLLightFrame
+ (STLLightFrame *)frameWithHub:(STLHub *)hub {
    STLLightFrame *frame = [self new];
    frame.hub = hub;
    
    return frame;
}
- (instancetype)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        strFrame = [json objectForKey:@"frame"];
        self.hub = [[STLDataManager sharedManager] hubWithIdentifier:[json objectForKey:@"hub"]];
    }
    return self;
}
- (NSString *)absoluteFrame {
    return strFrame;
}
- (void)reloadFrame {
    strFrame = @"";
    
    for (STLLight *light in self.hub.lights) {
        if (self.stateForLight(light) == YES) {
            strFrame = [NSString stringWithFormat:@"%@%@%@",strFrame,(light.position < 10 ? [NSString stringWithFormat:@"0%ld",(long)light.position] : [NSString stringWithFormat:@"%ld",(long)light.position]),[[self.colorForLight(light) hexValue] stringByReplacingOccurrencesOfString:@"#" withString:@""]];
        }
    }
}
- (void)enumerateFrame:(void (^)(NSString *, NSInteger))block {
    for (NSInteger x = 0; x < self.absoluteFrame.length/8; x++) {
        NSString *strLine = [self.absoluteFrame substringFromIndex:8*x];
        if (strLine.length > 8) strLine = [strLine substringToIndex:8];
        block([strLine substringFromIndex:2],[[strLine substringToIndex:2] integerValue]);
    }
}
- (NSDictionary *)JSON {
    NSMutableDictionary *dictJSON = [NSMutableDictionary new];
    
    [dictJSON setObject:self.hub.identifer forKey:@"hub"];
    [dictJSON setObject:strFrame forKey:@"frame"];
    
    return dictJSON;
}
@end
