//
//  STLHub+Private.h
//  StarLight
//
//  Created by Brian Olencki on 12/22/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLHub.h"

@interface STLHub (Private)
+ (NSSet*)allHubs;
+ (void)resetHubs;
+ (BOOL)removeHub:(STLHub*)hub;
@end
