//
//  STLDesignView.m
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLDesignView.h"
#import "NS2DArray.h"
#import "STLLightFrame.h"
#import "STLHub.h"
#import "STLLight.h"

#import <Chameleon.h>

@interface STLDesignView () {
    BOOL mouseSwiped;
    
    CGFloat lineSize;
    
    UIImageView *imgViewDrawing;
    
    NS2DArray *states;
    NS2DArray *colors;
    STLLightFrame *lightFrame;
}
@end

@implementation STLDesignView
+ (UIImage *)imageFromFrame:(STLLightFrame *)frame {
    STLDesignView *designView = [[STLDesignView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds)) withFrame:frame];
    UIImage *image = [UIImage imageWithCGImage:designView.image.CGImage];
    designView = nil;
    return image;
}
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
- (instancetype)initWithFrame:(CGRect)frame withFrame:(STLLightFrame *)lFrame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
        if (lFrame) {
            [self updateValuesForMatrixSize:lFrame.hub.matrix];
            [self setLightFrame:lFrame];
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
- (void)setLightFrame:(STLLightFrame *)lFrame {
    [self erase];
    lightFrame = lFrame;
    
    [lightFrame enumerateFrame:^(NSString *hexColor, NSInteger position) {
        self.drawColor = [UIColor colorWithHexString:hexColor];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(position % states.sections) inSection:(int)(position/states.sections)];
        [self highlightAtIndex:indexPath];
    }];
}
- (STLLightFrame *)lightFrame {
    for (STLLight *light in lightFrame.hub.lights) {
        if ([[states objectAtIndexPath:[NSIndexPath indexPathForRow:(light.position % states.sections) inSection:(light.position % states.sections)]] boolValue] == YES) {
            light.on = YES;
        }
    }
    
    [lightFrame setStateForLight:^BOOL(STLLight *light) {
        return light.on;
    }];
    
    __weak typeof(NS2DArray*) weakColors = colors;
    [lightFrame setColorForLight:^UIColor *(STLLight *light) {
        return [weakColors objectAtIndexPath:[NSIndexPath indexPathForRow:(light.position % states.sections) inSection:(light.position % states.sections)]];
    }];
    [lightFrame reloadFrame];
    
    return lightFrame;
}
- (void)updateValuesForMatrixSize:(NSIndexPath*)size {
    _size = size;
    
    states = [NS2DArray arrayWithSections:size.section rows:size.row];
    colors = [NS2DArray arrayWithSections:size.section rows:size.row];
    for (NSInteger section = 0; section < states.sections; section++) {
        for (NSInteger row = 0; row < states.rows; row++) {
            [states setObject:[NSNumber numberWithBool:NO] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            [colors setObject:[UIColor clearColor] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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
    for (NSInteger section = 0; section < states.sections; section++) {
        for (NSInteger row = 0; row < states.rows; row++) {
            [states setObject:[NSNumber numberWithBool:NO] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            [colors setObject:[UIColor clearColor] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }
    _empty = YES;
    if (self.didFinishDrawing) self.didFinishDrawing(self.image,self.lightFrame);
}
- (void)highlightAtIndex:(NSIndexPath*)indexPath {
    if (indexPath.row < states.rows && indexPath.section < states.sections) {
        [states setObject:[NSNumber numberWithBool:YES] atIndexPath:indexPath];
        [colors setObject:self.drawColor atIndexPath:indexPath];
        
        CGPoint currentPoint = CGPointMake((indexPath.row*(CGRectGetWidth(imgViewDrawing.frame)/states.rows))+((CGRectGetWidth(self.frame)/fmin(states.sections, states.rows))/2),(indexPath.section*(CGRectGetHeight(imgViewDrawing.frame)/states.sections))+((CGRectGetWidth(self.frame)/fmin(states.sections, states.rows))/2));

        UIGraphicsBeginImageContext(self.frame.size);
        [self.drawColor set];
        [imgViewDrawing.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x+1, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapSquare);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), lineSize);

        CGContextStrokePath(UIGraphicsGetCurrentContext());
        imgViewDrawing.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _empty = NO;
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
    NSInteger row = (self.size.row*self.size.section)*((currentPoint.x/CGRectGetWidth(self.frame))/(states.sections));
    NSInteger section = (self.size.row*self.size.section)*((currentPoint.y/CGRectGetHeight(self.frame))/(states.rows));
    if (row < states.rows && section < states.sections) {
        [states setObject:[NSNumber numberWithBool:YES] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        [self highlightAtIndex:[NSIndexPath indexPathForRow:row inSection:section]];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _drawing = NO;
    if (self.didFinishDrawing) self.didFinishDrawing(self.image,self.lightFrame);
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _drawing = NO;
}
@end
