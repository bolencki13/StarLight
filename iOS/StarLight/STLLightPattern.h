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

@class NS2DArray, STLHub, STLLightFrame;
@interface STLLightPattern : NSObject
@property (nonatomic, retain) STLHub *hub;
@property (nonatomic, retain) NSArray<STLLightFrame*> *frames;
@property (nonatomic) NSInteger delay;
@property (nonatomic, retain, readonly) NSString *absolutePattern;
@property (nonatomic, retain, readonly) NSData *dataPattern;
+ (NSString*)frameIdentifier;
+ (STLLightPattern*)patternWithFrames:(NSArray<STLLightFrame*>*)frames;
- (instancetype)initWithJSON:(NSDictionary*)json;
- (NSDictionary*)JSON;
@end
