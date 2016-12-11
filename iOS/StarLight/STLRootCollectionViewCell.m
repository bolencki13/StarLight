//
//  STLRootCollectionViewCell.m
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLRootCollectionViewCell.h"

#import <ChameleonFramework/Chameleon.h>

@implementation STLRootCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}
- (void)sharedInit {
    self.layer.cornerRadius = 7.5;
    self.layer.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 8.0;
    self.layer.shadowOffset = CGSizeZero;
    self.contentView.layer.cornerRadius = self.layer.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    _designView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, CGRectGetHeight(self.frame)-30, CGRectGetHeight(self.frame)-30)];
    _designView.layer.cornerRadius = self.layer.cornerRadius;
    _designView.backgroundColor = [UIColor colorWithHexString:@"EEF9FF"];
    _designView.layer.borderColor = [UINavigationBar appearance].barTintColor.CGColor;
    _designView.layer.borderWidth = 1.0;
    [self.contentView addSubview:_designView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_designView.frame)+10, CGRectGetMinY(_designView.frame)+12.5, CGRectGetWidth(self.frame)-10-CGRectGetMaxX(_designView.frame)-10, CGRectGetHeight(_designView.frame)/2)];
    _titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]+6];
    _titleLabel.textColor = [UIColor colorWithCGColor:_designView.layer.borderColor];
    [self.contentView addSubview:_titleLabel];
    
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_designView.frame)+10, CGRectGetMaxY(_titleLabel.frame)-10, CGRectGetWidth(_titleLabel.frame), CGRectGetHeight(_titleLabel.frame))];
    _locationLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    _locationLabel.textColor = [_titleLabel.textColor colorWithAlphaComponent:0.8];
    [self.contentView addSubview:_locationLabel];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_titleLabel sizeToFit];
    [_locationLabel sizeToFit];
}
@end
