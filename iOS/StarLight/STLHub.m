//
//  STLHub.m
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLHub.h"
#import "STLLight.h"
#import "NS2DArray.h"

@implementation STLHub
static NSMutableSet *hubs = nil;
+ (NSSet*)allHubs {
    return hubs;
}
+ (void)resetHubs {
    [hubs removeAllObjects];
}
+ (BOOL)removeHub:(STLHub*)hub {
    STLHub *hubRemove = nil;
    for (STLHub *_hub in [self allHubs]) {
        if ([_hub.identifer isEqualToString:hub.identifer]) {
            hubRemove = _hub;
            break;
        }
    }
    
    if (hubRemove) {
        [hubs removeObject:hubRemove];
    }
    return (hubRemove != nil);
}
+ (void)initialize {
    if (!hubs) {
        hubs = [NSMutableSet new];
    }
}
- (void)dealloc {
    [hubs removeObject:self];
}

#pragma mark - Initalization
+ (STLHub*)hub {
    STLHub *hub = [[STLHub alloc] init];
    hub.name = [NSString stringWithFormat:@"Hub #%ld",(unsigned long)[[STLHub allHubs] count]];
    hub.location = @"Backyard";
    hub.matrix = [NSIndexPath indexPathForRow:0 inSection:0];
    hub.identifer = @"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx";
    
    return hub;
}
+ (STLHub *)hubWithLights:(NSSet *)lights {
    STLHub *hub = [STLHub hub];
    hub.lights = lights;
    
    for (STLLight *light in lights) {
        light.hub = hub;
    }
    
    return hub;
}
+ (STLHub *)hubWithJSON:(NSDictionary *)json {
    STLHub *hub = [STLHub hub];
    hub.name = [json objectForKey:@"name"];
    hub.location = [json objectForKey:@"location"];
    hub.matrix = [NSIndexPath indexPathForRow:[[[json objectForKey:@"matrix"] objectForKey:@"rows"] integerValue] inSection:[[[json objectForKey:@"matrix"] objectForKey:@"sections"] integerValue]];
    hub.identifer = [json objectForKey:@"identifier"];
    
    NSMutableSet *setLights = [NSMutableSet new];
    for (NSDictionary *light in json[@"lights"]) {
        [setLights addObject:[STLLight lightWithJSON:light]];
    }
    hub.lights = setLights;
    
    return hub;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}
- (void)sharedInit {
    self.lights = [NSSet new];
    
    if (![hubs containsObject:self]) [hubs addObject:self];
}
- (void)setLights:(NSSet<STLLight *> *)lights {
    _lights = lights;
    
    for (STLLight *light in lights) {
        light.hub = self;
    }
}
- (NSDictionary *)JSON {
    NSMutableDictionary *json = [NSMutableDictionary new];
    [json setObject:self.name forKey:@"name"];
    [json setObject:self.location forKey:@"location"];
    [json setObject:@{
                      @"rows" : [NSNumber numberWithInteger:self.matrix.row],
                      @"sections" : [NSNumber numberWithInteger:self.matrix.section]
                      } forKey:@"matrix"];
    [json setObject:self.identifer forKey:@"identifier"];
    
    NSMutableArray *aryLights = [NSMutableArray new];
    for (STLLight *light in self.lights) {
        [aryLights addObject:[light JSON]];
    }
    [json setObject:aryLights forKey:@"lights"];
    return json;
}
- (NS2DArray*)lightMatrix {
    NS2DArray *matrix = [NS2DArray arrayWithSections:self.matrix.section rows:self.matrix.row];
    
    // need to populate with 'dummy' values otherwise will crash when trying to insert if index does not exist
    for (NSInteger section = 0; section < matrix.sections; section++) {
        for (NSInteger row = 0; row < matrix.rows; row++) {
            [matrix setObject:[NSNumber numberWithInteger:-1] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }
    
    for (NSInteger section = 0; section < matrix.sections; section++) {
        for (NSInteger row = 0; row < matrix.rows; row++) {
            STLLight *light = [self lightAtIndex:(section*(matrix.rows))+row];
            if (light) [matrix setObject:[NSNumber numberWithInteger:light.index] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }
    
    return matrix;
}

#pragma mark - Private
- (STLLight*)lightAtIndex:(NSInteger)index {
    STLLight *light = nil;
    for (STLLight *_light in self.lights) {
        if (_light.index == index) {
            light = _light;
            break;
        }
    }
    return light;
}
@end
