//
//  STLHub.h
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STLLight, NS2DArray, STLLightPattern;
@interface STLHub : NSObject
@property (nonatomic, retain) NSString *identifer;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSIndexPath *matrix;
@property (nonatomic, retain) NSSet <STLLight *> *lights;
@property (nonatomic, retain) STLLightPattern *pattern;
+ (STLHub*)hub;
+ (STLHub*)hubWithLights:(NSSet*)lights;
+ (STLHub*)hubWithJSON:(NSDictionary*)json;
- (NSDictionary*)JSON;
- (NS2DArray*)lightMatrix;
@end
