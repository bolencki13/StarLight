//
//  STLDesignView.m
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLDesignView.h"
#import "NS2DArray.h"
#import "STLLightPattern.h"
#import "STLHub.h"

@interface STLDesignView () {
    BOOL mouseSwiped;
    
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
- (instancetype)initWithFrame:(CGRect)frame withImage:(UIImage *)image withHub:(STLHub*)hub withStates:(NS2DArray *)states {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
        imgViewDrawing.image = image;
        _hub = hub;
        if (states) {
            [self updateValuesForMatrixSize:[NSIndexPath indexPathForRow:states.rows inSection:states.sections]];
            _states = states;
        }
    }
    return self;
}
- (void)sharedInit {
    _drawing = NO;
    [self updateValuesForMatrixSize:[NSIndexPath indexPathForRow:10 inSection:10]];
    
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
- (void)updateValuesForMatrixSize:(NSIndexPath*)size {
    _lightPattern = [STLLightPattern patternForHub:_hub];
    _states = [NS2DArray arrayWithSections:size.section rows:size.row];
    for (NSInteger section = 0; section < _states.sections; section++) {
        for (NSInteger row = 0; row < _states.rows; row++) {
            [_states setObject:[NSNumber numberWithBool:NO] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }
    
    lineSize = CGRectGetWidth(self.frame)/fmin(size.section, size.row);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (NSInteger section = 1; section < size.section; section++) {
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(imgViewDrawing.frame)/size.section*section)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(imgViewDrawing.frame), CGRectGetHeight(imgViewDrawing.frame)/size.section*section)];
    }
    for (NSInteger row = 1; row < size.row; row++) {
        [path moveToPoint:CGPointMake(CGRectGetWidth(imgViewDrawing.frame)/size.row*row, 0)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(imgViewDrawing.frame)/size.row*row, CGRectGetHeight(imgViewDrawing.frame))];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] CGColor];
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = shapeLayer.strokeColor;
    [self.layer addSublayer:shapeLayer];
    
    [self bringSubviewToFront:imgViewDrawing];
}
- (void)erase {
    imgViewDrawing.image = [UIImage new];
    for (NSInteger section = 0; section < _states.sections; section++) {
        for (NSInteger row = 0; row < _states.rows; row++) {
            [_states setObject:[NSNumber numberWithBool:NO] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }
    if (self.didFinishDrawing) self.didFinishDrawing(self.image,self.states, self.lightPattern);
}
- (void)highlightAtIndex:(NSIndexPath *)indexPath {
    if (indexPath.row < _states.rows && indexPath.section < _states.sections) {
        [_states setObject:[NSNumber numberWithBool:YES] atIndexPath:indexPath];
        
        CGPoint currentPoint = CGPointMake((indexPath.row*(CGRectGetWidth(imgViewDrawing.frame)/_states.rows))+((CGRectGetWidth(self.frame)/fmin(_states.sections, _states.rows))/2),(indexPath.section*(CGRectGetHeight(imgViewDrawing.frame)/_states.sections))+((CGRectGetWidth(self.frame)/fmin(_states.sections, _states.rows))/2));
        
        UIGraphicsBeginImageContext(self.frame.size);
        [imgViewDrawing.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x+1, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapSquare);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), lineSize);
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UINavigationBar appearance].barTintColor.CGColor);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        imgViewDrawing.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _drawing = YES;
    mouseSwiped = NO;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    if (!CGRectContainsPoint(self.bounds,currentPoint)) return;
    
    // logic for adding drawing state to NS2DArray (needs to convert CGRect relative to NSIndexPath)
    NSInteger row = 100*((currentPoint.x/CGRectGetWidth(self.frame))/(_states.sections+1));
    NSInteger section = 100*((currentPoint.y/CGRectGetHeight(self.frame))/(_states.rows+1));
    if (row < _states.rows && section < _states.sections) {
        [_states setObject:[NSNumber numberWithBool:YES] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        [self highlightAtIndex:[NSIndexPath indexPathForRow:row inSection:section]];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _drawing = NO;
    if (self.didFinishDrawing) self.didFinishDrawing(self.image,self.states,self.lightPattern);
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _drawing = NO;
}
@end
