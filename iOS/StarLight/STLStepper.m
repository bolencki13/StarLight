//
//  STLStepper.m
//  StarLight
//
//  Created by Brian Olencki on 1/18/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import "STLStepper.h"

@interface STLStepper () {
    UILabel *lblValue;
}

@end

@implementation STLStepper
- (void)layoutSubviews {
    [super layoutSubviews];
    
    lblValue.frame = CGRectMake(0, 0, 40, CGRectGetHeight(self.frame));
    self.tintColor = self.color;
}
- (void)setValue:(double)value {
    [super setValue:value];
    
    if (!lblValue) {
        lblValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, CGRectGetHeight(self.frame))];
        lblValue.textAlignment = NSTextAlignmentCenter;
        lblValue.textColor = self.tintColor;
        lblValue.adjustsFontSizeToFitWidth = YES;
    }
    lblValue.text = [NSString stringWithFormat:@"%0.1f",self.value];
    UIGraphicsBeginImageContextWithOptions(lblValue.frame.size, NO, 0.0);
    [lblValue.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imgValue = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setDividerImage:imgValue forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
    [self setDividerImage:imgValue forLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateHighlighted
     ];
}
- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    lblValue.tintColor = self.tintColor;
    lblValue.textColor = self.tintColor;
    
    UIGraphicsBeginImageContextWithOptions(lblValue.frame.size, NO, 0.0);
    [lblValue.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imgValue = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setDividerImage:imgValue forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
}
@end
