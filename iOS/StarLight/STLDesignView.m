//
//  STLDesignView.m
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLDesignView.h"

@interface STLDesignView () {
    BOOL mouseSwiped;
    
    CGPoint lastPoint;
    CGFloat lineSize;
    
    UIImageView *imgViewDrawing;
}
@end

@implementation STLDesignView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame withImage:(UIImage *)image {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
        imgViewDrawing.image = image;
    }
    return self;
}
- (void)sharedInit {
    _drawing = NO;
    [self updateValuesForMatrixSize:CGSizeMake(10, 10)];
    
    self.layer.borderColor = [UINavigationBar appearance].barTintColor.CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 7.5;
    self.layer.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 8.0;
    self.layer.shadowOffset = CGSizeZero;

    self.backgroundColor = [UIColor whiteColor];
    
    imgViewDrawing = [[UIImageView alloc] initWithFrame:self.bounds];
    imgViewDrawing.layer.cornerRadius = self.layer.cornerRadius;
    imgViewDrawing.layer.masksToBounds = YES;
    [self addSubview:imgViewDrawing];
}
- (UIImage*)image {
    return (_drawing ? nil :imgViewDrawing.image);
}
- (void)setImage:(UIImage *)image {
    imgViewDrawing.image = image;
}
- (void)updateValuesForMatrixSize:(CGSize)size {
    lineSize = CGRectGetWidth(self.frame)/size.width*0.75;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (NSInteger section = 1; section < size.height; section++) {
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(imgViewDrawing.frame)/size.height*section)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(imgViewDrawing.frame), CGRectGetHeight(imgViewDrawing.frame)/size.height*section)];
    }
    for (NSInteger row = 1; row < size.width; row++) {
        [path moveToPoint:CGPointMake(CGRectGetWidth(imgViewDrawing.frame)/size.width*row, 0)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(imgViewDrawing.frame)/size.width*row, CGRectGetHeight(imgViewDrawing.frame))];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = [[UIColor grayColor] CGColor];
    [imgViewDrawing.layer addSublayer:shapeLayer];
}
- (void)erase {
    imgViewDrawing.image = nil;
    if (self.didFinishDrawing) self.didFinishDrawing(self.image);
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _drawing = YES;
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    UIGraphicsBeginImageContext(self.frame.size);
    [imgViewDrawing.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), lineSize);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UINavigationBar appearance].barTintColor.CGColor);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    imgViewDrawing.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _drawing = NO;
    if (self.didFinishDrawing) self.didFinishDrawing(self.image);
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _drawing = NO;
}
@end
