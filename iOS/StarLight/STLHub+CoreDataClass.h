//
//  STLHub+CoreDataClass.h
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#ifndef STLHUB_CLASS
#define STLHUB_CLASS

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STLLight, NS2DArray;

NS_ASSUME_NONNULL_BEGIN

@interface STLHub : NSManagedObject
+ (STLHub*)hub;
- (NS2DArray *)lightGrid;
@end

NS_ASSUME_NONNULL_END

#import "STLHub+CoreDataProperties.h"

#endif
