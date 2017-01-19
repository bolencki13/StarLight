//
//  STLRootCollectionViewCell.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NS2DArray;
@interface STLRootTableViewCell : UITableViewCell
@property (nonatomic, copy) void (^cellShouldBeRemoved)();
@property (nonatomic, copy) void (^cellShouldBeFlash)();
@property (nonatomic, copy) void (^cellDetailActivate)();
@property (nonatomic, copy) void (^cellLongHoldActivate)();
@property (nonatomic, retain) UIImage *drawImage;
@property (nonatomic, retain) NSArray<NS2DArray*> *states;
@property (nonatomic) NSInteger delay; // mm
+ (CGFloat)defaultCellHeight;
- (void)setTitle:(NSString*)title;
- (void)setLocation:(NSString*)location;
- (void)animate;
@end
