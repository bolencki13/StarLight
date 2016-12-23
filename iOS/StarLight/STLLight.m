//
//  STLLight.m
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLLight.h"
#import "STLHub.h"
#import "STLDataManager.h"

@implementation STLLight
+ (STLLight*)light {
    STLLight *light = [[STLLight alloc] init];
    light.position = 0;
    light.index = -1;
    light.on = NO;
    return light;
}
+ (STLLight*)lightWithHub:(STLHub *)hub {
    STLLight *light = [self light];
    
    NSMutableSet *setLights = [[hub lights] mutableCopy];
    [setLights addObject:light];
    [hub setLights:setLights];
    
    return light;
}
+ (STLLight*)lightWithJSON:(NSDictionary *)json {
    STLLight *light = [STLLight light];
    light.position = [[json objectForKey:@"position"] integerValue];
    light.index = [[json objectForKey:@"index"] integerValue];
    light.on = [[json objectForKey:@"on"] boolValue];

//    STLHub *hub = [[STLDataManager sharedManager] hubWithIdentifier:[json objectForKey:@"identifier"]];
//    NSMutableSet *setLights = [[hub lights] mutableCopy];
//    [setLights addObject:light];
//    [hub setLights:setLights];
    
    return light;
}
- (NSDictionary *)JSON {
    NSMutableDictionary *json = [NSMutableDictionary new];
    [json setObject:[NSNumber numberWithInteger:self.position] forKey:@"position"];
    [json setObject:[NSNumber numberWithInteger:self.index] forKey:@"index"];
    [json setObject:[NSNumber numberWithBool:self.on] forKey:@"on"];
    [json setObject:self.hub.identifer forKey:@"hub"];
    return json;
}
@end
