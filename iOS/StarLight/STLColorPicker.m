//
//  NFLColorPicker.m
//  NotificationLights
//
//  Created by Brian Olencki on 2/3/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import "STLColorPicker.h"

@interface STLColorPicker () {
    UIImageView *imgViewColor;
    
    UIView *viewColor;
    UIImageView *imgViewColorPicked;
    UILabel *lblColor;
    
    UILongPressGestureRecognizer *lpgrColorPicker;
}

@end

@implementation STLColorPicker
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
- (void)sharedInit {
    self.tintColor = [UIColor whiteColor];
    
    imgViewColor = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-(CGRectGetHeight(self.frame)), 10, CGRectGetHeight(self.frame)-20, CGRectGetHeight(self.frame)-20)];
    imgViewColor.layer.cornerRadius = CGRectGetHeight(imgViewColor.frame)/2;
    imgViewColor.layer.borderColor = self.tintColor.CGColor;
    imgViewColor.layer.borderWidth = 3.5;
    imgViewColor.image = [UIImage imageNamed:@"ColorWheel"];
    imgViewColor.contentMode = UIViewContentModeScaleAspectFit;
    imgViewColor.userInteractionEnabled = YES;
    [self addSubview:imgViewColor];
    
    _viewCenter = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(imgViewColor.frame)/4, CGRectGetWidth(imgViewColor.frame)/4, CGRectGetWidth(imgViewColor.frame)/2, CGRectGetWidth(imgViewColor.frame)/2)];
    _viewCenter.backgroundColor = self.tintColor;
    _viewCenter.layer.cornerRadius = CGRectGetWidth(_viewCenter.frame)/2;
    [imgViewColor addSubview:_viewCenter];
    
    viewColor = [[UIView alloc] initWithFrame:CGRectMake(20, (CGRectGetHeight(self.frame)-115)/2, 75, 115)];
    viewColor.backgroundColor = self.tintColor;
    viewColor.layer.masksToBounds = YES;
    viewColor.layer.cornerRadius = 8;
    viewColor.layer.borderColor = self.tintColor.CGColor;
    viewColor.layer.borderWidth = imgViewColor.layer.borderWidth;
    [self addSubview:viewColor];
    
    imgViewColorPicked = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(viewColor.frame)-80, CGRectGetWidth(viewColor.frame), 80)];
    imgViewColorPicked.layer.masksToBounds = YES;
    [viewColor addSubview:imgViewColorPicked];
    
    lblColor = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewColor.frame), 30)];
    lblColor.textAlignment = NSTextAlignmentCenter;
    lblColor.font = [UIFont systemFontOfSize:[UIFont systemFontSize]-2];
    [viewColor addSubview:lblColor];
    
    self.color = self.tintColor;
    
    lpgrColorPicker = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    lpgrColorPicker.minimumPressDuration = 0.0;
    [imgViewColor addGestureRecognizer:lpgrColorPicker];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    imgViewColor.frame = CGRectMake(CGRectGetWidth(self.frame)-(CGRectGetHeight(self.frame)), 10, CGRectGetHeight(self.frame)-20, CGRectGetHeight(self.frame)-20);
    imgViewColor.layer.cornerRadius = CGRectGetHeight(imgViewColor.frame)/2;

    _viewCenter.frame = CGRectMake(CGRectGetWidth(imgViewColor.frame)/4, CGRectGetWidth(imgViewColor.frame)/4, CGRectGetWidth(imgViewColor.frame)/2, CGRectGetWidth(imgViewColor.frame)/2);
    _viewCenter.layer.cornerRadius = CGRectGetWidth(_viewCenter.frame)/2;
    
    viewColor.frame = CGRectMake(20, (CGRectGetHeight(self.frame)-115)/2, 75, 115);
    viewColor.layer.borderColor = self.tintColor.CGColor;
    
    lblColor.frame = CGRectMake(0, 0, CGRectGetWidth(viewColor.frame), 30);
    
    imgViewColorPicked.frame = CGRectMake(0, CGRectGetHeight(viewColor.frame)-80, CGRectGetWidth(viewColor.frame), 80);
}

#pragma mark - Gestures
- (void)handlePan:(UIPanGestureRecognizer*)recognizer {
    CGPoint tap = [recognizer locationInView:imgViewColor];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (CGRectContainsPoint(imgViewColor.frame, [recognizer locationInView:self])) {
            if (CGRectContainsPoint(_viewCenter.frame, tap)) {
                if (self.tappedCenter) self.tappedCenter();
            } else {
                self.color = [self colorForPoint:tap];
            }
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (CGRectContainsPoint(imgViewColor.frame, [recognizer locationInView:self])) {
            if (!CGRectContainsPoint(_viewCenter.frame, tap)) {
                self.color = [self colorForPoint:tap];
            }
        }
    }
}

#pragma mark - Color
- (void)setColor:(UIColor *)color {
    _color = color;
    
    imgViewColorPicked.image = [self imageFromColor:_color];
    lblColor.text = [self hexFromUIColor:_color];
}
- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    
    imgViewColor.layer.borderColor = _tintColor.CGColor;
    _viewCenter.backgroundColor = _tintColor;
    viewColor.backgroundColor = _tintColor;
}
- (UIImage*)imageFromColor:(UIColor*)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (NSString*)hexFromUIColor:(UIColor*)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}
- (UIColor*)colorForPoint:(CGPoint)point {
    
    UIColor *color = nil;
    CGImageRef inImage;
    
    inImage = imgViewColor.image.CGImage;
    
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) {
        return nil;
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);

    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    if (data) {
        free(data);
    }
    
    return color;
}
- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    bitmapBytesPerRow = (int)(pixelsWide * 4);
    bitmapByteCount = (int)(bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL) {
        return NULL;
    }
    
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL) {
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);
    if (context == NULL) {
        free(bitmapData);
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}
@end
