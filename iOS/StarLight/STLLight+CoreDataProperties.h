//
//  STLLight+CoreDataProperties.h
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#ifndef STLLIGHT_PROPERTIES
#define STLLIGHT_PROPERTIES

#import "STLLight+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface STLLight (CoreDataProperties)

+ (NSFetchRequest<STLLight *> *)fetchRequest;

@property (nonatomic) BOOL on;
@property (nullable, nonatomic, retain) NSData *coordinate;
@property (nullable, nonatomic, retain) STLHub *hub;

@end

NS_ASSUME_NONNULL_END

#endif
