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
@property (nonatomic, copy) void (^cellDetailActivate)();
@property (nonatomic, retain) UIImage *drawImage;
@property (nonatomic, retain) NS2DArray *states;
+ (CGFloat)defaultCellHeight;
- (void)setTitle:(NSString*)title;
- (void)setLocation:(NSString*)location;
@end
