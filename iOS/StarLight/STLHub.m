//
//  STLHub.m
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLHub.h"
#import "STLLight.h"

@implementation STLHub
+ (STLHub*)hub {
    static NSInteger count;
    STLHub *hub = [[STLHub alloc] init];
    hub.name = [NSString stringWithFormat:@"Hub #%ld",(long)count];
    hub.location = @"Backyard";
    return hub;
}
+ (STLHub *)hubWithLights:(NSSet *)lights {
    STLHub *hub = [STLHub hub];
    hub.lights = lights;
    
    return hub;
}
+ (STLHub *)hubWithJSON:(NSDictionary *)json {
    STLHub *hub = [STLHub hub];
    hub.name = [json objectForKey:@"name"];
    hub.location = [json objectForKey:@"location"];
    
    NSMutableSet *setLights = [NSMutableSet new];
    for (NSDictionary *light in json[@"lights"]) {
        [setLights addObject:[STLLight lightWithJSON:light]];
    }
    hub.lights = setLights;
    
    return hub;
}
- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.lights = [decoder decodeObjectForKey:@"lights"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.lights forKey:@"lights"];
}
- (NSDictionary *)JSON {
    NSMutableDictionary *json = [NSMutableDictionary new];
    [json setObject:self.name forKey:@"name"];
    [json setObject:self.location forKey:@"location"];
    
    NSMutableArray *aryLights = [NSMutableArray new];
    for (STLLight *light in self.lights) {
        [aryLights addObject:[light JSON]];
    }
    [json setObject:aryLights forKey:@"lights"];
    return json;
}
@end
