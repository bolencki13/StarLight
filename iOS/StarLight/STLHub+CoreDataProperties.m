//
//  STLHub+CoreDataProperties.m
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "STLHub+CoreDataProperties.h"

@implementation STLHub (CoreDataProperties)

+ (NSFetchRequest<STLHub *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Hub"];
}

@dynamic name;
@dynamic location;
@dynamic lights;

@end
