//
//  NS2DArray+CGRect.m
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "NS2DArray+CGRect.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@implementation NS2DArray (CGRect)
+ (NS2DArray *)arrayFromCoordinates:(NSArray*)coordinates {
    NSArray *aryX = [coordinates sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        CGRect rect1 = [obj1 CGRectValue];
        CGRect rect2 = [obj2 CGRectValue];
        
        if (CGRectGetMinX(rect1) > CGRectGetMinX(rect2)) {
            return NSOrderedDescending;
        } else if (CGRectGetMinX(rect1) < CGRectGetMinX(rect2)) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    NSArray *aryY = [coordinates sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        CGRect rect1 = [obj1 CGRectValue];
        CGRect rect2 = [obj2 CGRectValue];
        
        if (CGRectGetMinY(rect1) > CGRectGetMinY(rect2)) {
            return NSOrderedDescending;
        } else if (CGRectGetMinY(rect1) < CGRectGetMinY(rect2)) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];

    NS2DArray *matrix = [NS2DArray arrayWithSections:[coordinates count] rows:[coordinates count]];
    
    /*
     
     -1 ==> no light
     # ==> light position
     
     */
    
    // need to populate with 'dummy' values otherwise will crash when trying to insert if index does not exist
    for (NSInteger section = 0; section < matrix.sections; section++) {
        for (NSInteger row = 0; row < matrix.rows; row++) {
            [matrix setObject:[NSNumber numberWithInteger:-1] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }
    
    for (NSInteger section = 0; section < matrix.sections; section++) {
        CGRect rectX = [[aryX objectAtIndex:section] CGRectValue];
        for (NSInteger row = 0; row < matrix.rows; row++) {
            CGRect rectY = [[aryY objectAtIndex:row] CGRectValue];
            if (CGRectEqualToRect(rectX, rectY)) {
                [matrix setObject:[NSNumber numberWithInteger:(section*(matrix.rows))+row] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                break;
            }
        }
    }
    
    return matrix;
}
@end
