//
//  STLLight+CoreDataProperties.m
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "STLLight+CoreDataProperties.h"

@implementation STLLight (CoreDataProperties)

+ (NSFetchRequest<STLLight *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Light"];
}

@dynamic on;
@dynamic coordinate;
@dynamic hub;

@end
