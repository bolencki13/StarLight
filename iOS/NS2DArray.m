//
//  NS2DArray.m
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "NS2DArray.h"

#import <UIKit/UIKit.h>

@interface NS2DArray () {
    NSMutableArray *masterObjects;
}

@end

@implementation NS2DArray
+ (NS2DArray*)arrayWithSections:(NSInteger)sections rows:(NSInteger)rows {
    return [[self alloc] initWithSections:sections rows:rows];
}
- (instancetype)initWithSections:(NSInteger)sections rows:(NSInteger)rows {
    self = [super init];
    if (self) {
        _sections = sections;
        _rows = rows;
        
        masterObjects = [NSMutableArray arrayWithCapacity:self.sections];
        for (NSInteger x = 0; x < _sections; x++) {
            [masterObjects addObject:[NSMutableArray arrayWithCapacity:self.rows]];
        }
    }
    return self;
}
- (id)objectAtIndexPath:(NSIndexPath*)indexPath {
    return [[masterObjects objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}
- (void)setObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
    masterObjects[indexPath.section][indexPath.row] = object;
}
- (void)removeObjects {
    masterObjects = [NSMutableArray arrayWithCapacity:self.sections];
    for (NSInteger x = 0; x < _sections; x++) {
        [masterObjects addObject:[NSMutableArray arrayWithCapacity:self.rows]];
    }
}
- (NSIndexPath *)indexPathForObject:(id)object {
    NSIndexPath *indexPath = nil;
    for (NSInteger section = 0; section < self.sections; section++) {
        BOOL shouldExit = NO;
        for (NSInteger row = 0; row < self.rows; row++) {
            if ([masterObjects[section][row] isEqual:object]) {
                indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                shouldExit = YES;
                break;
            }
        }
        if (shouldExit) break;
    }
    return indexPath;
}
- (NSString *)description {
    NSMutableString *description = [[super description] mutableCopy];
    
    for (NSUInteger section = 0; section < self.sections; section++) {
        for (NSUInteger row = 0; row < self.rows; row++) {
            id object = masterObjects[section][row];
            [description appendFormat:@"%@", object];
        }
        [description appendString:@"\n"];
    }
    
    return description;
}
@end
