//
//  STLDataManager.h
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLHub.h"
#import "STLLight.h"

@interface STLDataManager : NSObject
+ (instancetype)sharedManager;
- (BOOL)saveData:(NSError **)error;
- (STLHub*)registerHubWithLights:(NSArray<NSValue*>*)lights error:(NSError**)error;
- (STLHub*)hubWithName:(NSString*)name;
- (NSSet<STLHub*>*)hubs;
@end
