//
//  STLLightPattern.h
//  StarLight
//
//  Created by Brian Olencki on 12/26/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//
//  Will return the pattern string that is passed to the board
//
//  FORMAT:
//
//  delay
//  \n
//  frame1:
//    #color
//  frame...
//  \n
//
//
// If light number does not exist in frame turn light off
//

#import <UIKit/UIKit.h>

@class NS2DArray;
@interface STLLightPattern : NSObject
@property (nonatomic, retain) NSArray<NS2DArray*> *states;
@property (nonatomic, retain) NS2DArray *lights;
@property (nonatomic) uint32_t delay;
@property (nonatomic, copy) UIColor* (^colorForLightIndexWithFrame)(NSInteger lightIndex, NSInteger frame);
@property (nonatomic, retain, readonly) NSString *absolutePattern;
@property (nonatomic, retain, readonly) NSData *dataPattern;
+ (STLLightPattern*)pattern;
- (void)reloadPattern;
@end
