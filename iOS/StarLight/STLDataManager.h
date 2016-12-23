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

extern NSString * const STLDataManagerDidFinishLoadingData;

typedef void (^STLDataManagerDidFinishLoading)(NSArray *hubs);

@class NS2DArray;
@interface STLDataManager : NSObject
+ (instancetype)sharedManager;
- (BOOL)saveData:(NSError **)error;
- (STLHub*)registerHubWithLights:(NS2DArray*)indexes withPositions:(NSDictionary*)positions;
- (STLHub*)hubWithIdentifier:(NSString*)identifier;
- (NSSet<STLHub*>*)hubs;
- (void)reloadData:(STLDataManagerDidFinishLoading)complete;
@end
