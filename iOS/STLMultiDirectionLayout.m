//
//  STLMultiDirectionLayout.m
//  StarLight
//
//  Created by Brian Olencki on 12/10/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//
//http://stackoverflow.com/questions/15549233/view-with-continuous-scroll-both-horizontal-and-vertical

#import "STLMultiDirectionLayout.h"

@implementation STLMultiDirectionLayout
- (CGSize)collectionViewContentSize {
    NSInteger rows = 0;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        if ([self.collectionView numberOfItemsInSection:section] > rows) rows = [self.collectionView numberOfItemsInSection:section];
    }
    
    NSInteger x = rows * (self.itemSize.width);
    NSInteger y = [self.collectionView numberOfSections] * (self.itemSize.height+5.5);
    return CGSizeMake(x, y);
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    attributes.size = self.itemSize;
    NSInteger x = self.itemSize.width/2 + path.row * (self.itemSize.width);
    NSInteger y = self.itemSize.height + path.section * (self.itemSize.height);
    attributes.center = CGPointMake(x, y);
    return attributes;
}
- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger minRow = (rect.origin.x > 0) ? rect.origin.x/(self.itemSize.width) : 0;
    NSInteger maxRow = rect.size.width/(self.itemSize.width) + minRow;
    NSMutableArray *attributes = [NSMutableArray array];
    for(NSInteger i=0 ; i < self.collectionView.numberOfSections; i++) {
        for (NSInteger j=minRow ; j < (maxRow > [self.collectionView numberOfItemsInSection:i] ? [self.collectionView numberOfItemsInSection:i] : maxRow); j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    return attributes;
}
@end
