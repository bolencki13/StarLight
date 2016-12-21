//
//  STLHub.h
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STLLight;
@interface STLHub : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSSet <STLLight *> *lights;
+ (STLHub*)hub;
+ (STLHub*)hubWithLights:(NSSet*)lights;
+ (STLHub*)hubWithJSON:(NSDictionary*)json;
- (NSDictionary*)JSON;
@end
