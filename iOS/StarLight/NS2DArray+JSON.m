//
//  NS2DArray+JSON.m
//  StarLight
//
//  Created by Brian Olencki on 1/18/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import "NS2DArray+JSON.h"

@interface NS2DArray (Private)
@property (nonatomic, retain, readonly) NSMutableArray *masterObjects;
@end

@implementation NS2DArray (JSON)
- (instancetype)initWithJSON:(NSArray *)json {
    self = [super init];
    if (self) {
        [self setValue:json forKey:@"_masterObjects"];
    }
    return self;
}
- (NSArray *)json {
    return self.masterObjects;
}
@end
