//
//  NS2DArray.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NS2DArray : NSObject
@property (nonatomic, readonly) NSInteger sections;
@property (nonatomic, readonly) NSInteger rows;
+ (NS2DArray*)arrayWithSections:(NSInteger)sections rows:(NSInteger)rows;
- (instancetype)initWithSections:(NSInteger)sections rows:(NSInteger)rows;
- (instancetype)initWith2DArray:(NS2DArray*)matrix;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (void)setObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
- (void)removeObjects;
- (NSIndexPath*)indexPathForObject:(id)object;
- (void)enumerateObjectsUsingBlock:(void(^)(id obj, NSIndexPath *indexPath, BOOL *stop))block;
@end
