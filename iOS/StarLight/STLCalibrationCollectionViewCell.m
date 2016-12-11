//
//  STLCalibrationCollectionViewCell.m
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLCalibrationCollectionViewCell.h"

@implementation STLCalibrationCollectionViewCell
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
    self.layer.borderColor = [UINavigationBar appearance].barTintColor.CGColor;
    self.layer.borderWidth = 1.0;
    self.contentView.layer.cornerRadius = self.layer.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(self.frame)-10, CGRectGetWidth(self.frame)-10)];
    _titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]+6];
    _titleLabel.textColor = [UIColor colorWithCGColor:self.layer.borderColor];
    [self.contentView addSubview:_titleLabel];
}
@end
