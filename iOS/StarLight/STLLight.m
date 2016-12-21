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
    light.coordinate = CGPointMake(0, 0);
    light.on = NO;
    return light;
}
+ (STLLight*)lightWithHub:(STLHub *)hub {
    STLLight *light = [self light];
    light.hub = hub;
    return light;
}
+ (STLLight*)lightWithJSON:(NSDictionary *)json {
    STLLight *light = [STLLight light];
    light.coordinate = [[json objectForKey:@"coordinate"] CGPointValue];
    light.on = [[json objectForKey:@"on"] boolValue];
    light.hub = [[STLDataManager sharedManager] hubWithName:[json objectForKey:@"name"]];

    return light;
}
- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.coordinate = [[decoder decodeObjectForKey:@"coordinate"] CGPointValue];
        self.on = [[decoder decodeObjectForKey:@"on"] boolValue];
        self.hub = [[STLDataManager sharedManager] hubWithName:[decoder decodeObjectForKey:@"name"]];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[NSValue valueWithCGPoint:self.coordinate] forKey:@"coordinate"];
    [encoder encodeObject:[NSNumber numberWithBool:self.on] forKey:@"on"];
    [encoder encodeObject:self.hub.name forKey:@"hub"];
}
- (NSDictionary *)JSON {
    NSMutableDictionary *json = [NSMutableDictionary new];
    [json setObject:[NSValue valueWithCGPoint:self.coordinate] forKey:@"coordinate"];
    [json setObject:[NSNumber numberWithBool:self.on] forKey:@"on"];
    [json setObject:@"hub" forKey:self.hub.name];
    return json;
}
@end
