//
//  STLHub+CoreDataProperties.h
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#ifndef STLHUB_PROPERTIES
#define STLHUB_PROPERTIES

#import "STLHub+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface STLHub (CoreDataProperties)

+ (NSFetchRequest<STLHub *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *location;
@property (nullable, nonatomic, retain) NSSet<STLLight *> *lights;

@end

@interface STLHub (CoreDataGeneratedAccessors)

- (void)addLightsObject:(STLLight *)value;
- (void)removeLightsObject:(STLLight *)value;
- (void)addLights:(NSSet<STLLight *> *)values;
- (void)removeLights:(NSSet<STLLight *> *)values;

@end

NS_ASSUME_NONNULL_END

#endif
