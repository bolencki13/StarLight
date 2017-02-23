//
//  STLLightFrame.h
//  StarLight
//
//  Created by Brian Olencki on 2/22/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STLHub, STLLight, NS2DArray;
@interface STLLightFrame : NSObject
@property (nonatomic, retain) STLHub *hub;
@property (nonatomic, copy) BOOL (^stateForLight)(STLLight *light);
@property (nonatomic, copy) UIColor *(^colorForLight)(STLLight *light);
+ (STLLightFrame*)frameWithHub:(STLHub*)hub;
- (instancetype)initWithJSON:(NSDictionary*)json;
- (NSString*)absoluteFrame;
- (void)reloadFrame;
- (void)enumerateFrame:(void(^)(NSString *hexColor, NSInteger position))block;
- (NSDictionary*)JSON;
@end
