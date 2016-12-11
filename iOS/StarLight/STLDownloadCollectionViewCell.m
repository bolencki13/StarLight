//
//  STLDownloadCollectionViewCell.m
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLDownloadCollectionViewCell.h"

@interface STLCalibrationCollectionViewCell (Private)
- (void)sharedInit;
@end

@implementation STLDownloadCollectionViewCell
- (void)sharedInit {
    [super sharedInit];
    
    _previewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
    _previewImage.layer.cornerRadius = self.layer.cornerRadius;
    _previewImage.layer.masksToBounds = YES;
    [self.contentView addSubview:_previewImage];
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel setFrame:CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetHeight(self.frame)-30, CGRectGetWidth(self.titleLabel.frame), 30)];
}
@end
