//
//  STLLight.h
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class STLHub;
@interface STLLight : NSObject
@property (nonatomic) CGPoint coordinate;
@property (nonatomic) BOOL on;
@property (nonatomic, retain) STLHub *hub;
+ (STLLight*)light;
+ (STLLight*)lightWithHub:(STLHub*)hub;
+ (STLLight*)lightWithJSON:(NSDictionary*)json;
- (NSDictionary*)JSON;
@end
