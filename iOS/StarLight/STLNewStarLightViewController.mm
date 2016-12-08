//
//  STLNewStarLightViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/6/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLNewStarLightViewController.h"

#import "BEMCheckBox.h"
#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h>

@interface STLNewStarLightViewController () <CvVideoCameraDelegate, BEMCheckBoxDelegate> {
    CvVideoCamera *camera;
    
    NSMutableArray <BEMCheckBox*> *aryLights;
    
    UIView *contentView;
}
@end

@implementation STLNewStarLightViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.navigationController.navigationBar.tintColor;
    
    camera = [[CvVideoCamera alloc] initWithParentView:self.view];
    camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
    camera.defaultFPS = 60;
    camera.delegate = self;
    [camera start];

    contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:contentView];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([camera running]) [camera stop];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lights
- (BEMCheckBox*)addLightToPoint:(CGPoint)point {
    BEMCheckBox *checkBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(0,0,30,30)];
    checkBox.delegate = self;
    checkBox.lineWidth = 3.5;
    [checkBox setOn:YES animated:NO];
    checkBox.center = point;
    [contentView addSubview:checkBox];
    
    if (!aryLights) {
        aryLights = [NSMutableArray new];
    }
    [aryLights addObject:checkBox];
    
    return checkBox;
}
- (void)removeAllLights {
    for (BEMCheckBox *checkBox in aryLights) {
        [checkBox removeFromSuperview];
    }
    [aryLights removeAllObjects];
}
- (void)removeLightClosestToPoint:(CGPoint)point withMarginOfError:(CGFloat)margin {
    BEMCheckBox *checkBox = [self lightClosestToPoint:point withMarginOrError:margin];
    if (checkBox) {
        [checkBox removeFromSuperview];
        [aryLights removeObject:checkBox];
    }
}
- (void)updateLightClosestToPoint:(CGPoint)point withMarginOfError:(CGFloat)margin maxLights:(NSInteger)max createIfNecessary:(BOOL)create {
    BEMCheckBox *checkBox = [self lightClosestToPoint:point withMarginOrError:margin];
    if (!checkBox && create) {
        if ([aryLights count] < max) checkBox = [self addLightToPoint:point];
    }
    
    if (checkBox) checkBox.center = point;
}
- (BEMCheckBox*)lightClosestToPoint:(CGPoint)point withMarginOrError:(CGFloat)margin {
    BEMCheckBox *checkBox = nil;
    for (BEMCheckBox *_checkBox in aryLights) {
        if (!checkBox) checkBox = _checkBox;
        else {
            if ([self distanceBetweenRect:_checkBox.frame andPoint:point] < [self distanceBetweenRect:checkBox.frame andPoint:point]) {
                checkBox = _checkBox;
            }
        }
    }
    
    if (margin == 0 || [self distanceBetweenRect:checkBox.frame andPoint:point] < margin) {
        return checkBox;
    } else {
        return nil;
    }
}

#pragma mark - Other
- (CGFloat)distanceBetweenRect:(CGRect)rect andPoint:(CGPoint)point {
    if (CGRectContainsPoint(rect, point)) return 0.f;
    
    CGPoint closest = rect.origin;
    if (rect.origin.x + rect.size.width < point.x)
        closest.x += rect.size.width;
    else if (point.x > rect.origin.x)
        closest.x = point.x;
    if (rect.origin.y + rect.size.height < point.y)
        closest.y += rect.size.height;
    else if (point.y > rect.origin.y)
        closest.y = point.y;
    
    CGFloat a = powf(closest.y-point.y, 2.f);
    CGFloat b = powf(closest.x-point.x, 2.f);
    return sqrtf(a + b);
}

#pragma mark - CvVideoCameraDelegate
- (void)processImage:(cv::Mat &)image {
    cv::Mat bgr_image = image.clone();    
    cv::medianBlur(bgr_image, bgr_image, 3);

    cv::Mat hsv_image;
    cv::cvtColor(bgr_image, hsv_image, cv::COLOR_BGR2HSV);

    cv::Mat lower_red_hue_range;
    cv::Mat upper_red_hue_range;
    cv::inRange(hsv_image, cv::Scalar(0, 100, 100), cv::Scalar(10, 255, 255), lower_red_hue_range);
    cv::inRange(hsv_image, cv::Scalar(160, 100, 100), cv::Scalar(179, 255, 255), upper_red_hue_range);

    cv::Mat red_hue_image;
    cv::addWeighted(lower_red_hue_range, 1.0, upper_red_hue_range, 1.0, 0.0, red_hue_image);
    cv::GaussianBlur(red_hue_image, red_hue_image, cv::Size(9, 9), 2, 2);

    std::vector<cv::Vec3f> circles;
    cv::HoughCircles(red_hue_image, circles, CV_HOUGH_GRADIENT, 1, red_hue_image.rows/8, 100, 20, 0, 15);

    if (circles.size() == 0) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            /* No valid lights found remove all check boxes */
            [self removeAllLights]; /* DEFINITLY is not the best way to do this */
        });
        return;
    }
    
    for(size_t current_circle = 0; current_circle < circles.size(); ++current_circle) {
        __block int y = std::round(circles[current_circle][0]);
        __block int x = std::round(circles[current_circle][1]);
        cv::Point center(y, x);
        __block int radius = std::round(circles[current_circle][2]);

#if DEBUG
        cv::circle(image, center, radius, cv::Scalar(0, 255, 0), 5);
#endif
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            CGPoint center = CGPointMake(x*(CGRectGetWidth(contentView.bounds)/image.rows), fabs(CGRectGetHeight(contentView.frame)-(y*(CGRectGetHeight(contentView.bounds)/image.cols))));
            [self updateLightClosestToPoint:center withMarginOfError:0 maxLights:circles.size() createIfNecessary:YES];
//        XXX: Broken need to figure out how to keep track of state and refresh BEMCheckBox's
        });
    }
}
@end
