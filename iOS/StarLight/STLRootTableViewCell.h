//
//  STLRootCollectionViewCell.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NS2DArray;

@interface STLRootTableViewCellButton : NSObject
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIColor *titleColor;
@property (nonatomic) SEL action;
@property (nonatomic, retain) id target;
+ (STLRootTableViewCellButton*)buttonWithTitle:(NSString*)title backgroundColor:(UIColor*)backgroundColor titleColor:(UIColor*)titleColor target:(id)target action:(SEL)selector;
@end

@interface STLRootTableViewCell : UITableViewCell
@property (nonatomic, copy) void (^cellShouldBeRemoved)();
@property (nonatomic, copy) void (^cellShouldBeFlash)();
@property (nonatomic, copy) void (^cellDetailActivate)();
@property (nonatomic, copy) void (^cellLongHoldActivate)();
@property (nonatomic, retain) UIImage *drawImage;
@property (nonatomic, retain) NSArray<NS2DArray*> *states;
@property (nonatomic, retain) NSArray<STLRootTableViewCellButton*> *rightButtons;
@property (nonatomic, retain) NSArray<STLRootTableViewCellButton*> *leftButtons;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic) NSInteger delay; // mm
+ (CGFloat)defaultCellHeight;
- (void)setTitle:(NSString*)title;
- (void)setLocation:(NSString*)location;
- (void)animate;
@end
