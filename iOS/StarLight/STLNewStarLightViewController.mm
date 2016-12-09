//
//  STLNewStarLightViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/6/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLNewStarLightViewController.h"

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h>

#define _DEBUG (1)

#define FPS (10)
#define MIN_AREA (10)
#define MAX_AREA (100)

CGRect CGRectFromCVRect(cv::Rect frame) {
    return CGRectMake(frame.x, frame.y, frame.width, frame.height);
}

cv::Scalar CVScalarFromUIColor(UIColor *color) {
    CGFloat red,green,blue,alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return cv::Scalar(blue*255, green*255, red*255, alpha*255);
}

@interface STLNewStarLightViewController () <CvVideoCameraDelegate> {
    CvVideoCamera *camera;
        
    UIView *contentView;
    
    cv::Mat initalFrame;
}
@end

@implementation STLNewStarLightViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.navigationController.navigationBar.tintColor;
    
    camera = [[CvVideoCamera alloc] initWithParentView:self.view];
    camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
    camera.defaultFPS = FPS;
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

#pragma mark - Image Handling 
- (void)imageStabalization:(cv::Mat &)image outputImage:(cv::Mat &)outImage {
    
}
- (BOOL)imageMotionTracking:(cv::Mat &)image outputImage:(cv::Mat &)outImage frame:(cv::Rect &)frame {
    cv::Mat frameDelta;
    cv::absdiff(initalFrame, image, frameDelta);
    
    cv::Mat threshold;
    cv::threshold(frameDelta, threshold, 25, 255, cv::THRESH_BINARY);
    cv::dilate(threshold, threshold, NULL, cv::Point(-1,-1),10);
    
    std::vector< std::vector<cv::Point> > contours;
    cv::findContours(threshold, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
    
    BOOL hasValidLight = NO;
    for (size_t i=0; i < contours.size(); i++) {
        if (cv::contourArea(contours[i]) < MIN_AREA || cv::contourArea(contours[i]) > MAX_AREA) continue;
        cv::Rect _frame = cv::boundingRect(contours[i]);
        cv::rectangle(outImage, _frame, CVScalarFromUIColor([UIColor blueColor]), 10, CV_AA);
        frame = _frame;
        hasValidLight = YES;
    }
    
    return hasValidLight;
}
- (void)alertWithImage:(UIImage*)image withTitle:(NSString*)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
    
    UIImageView *imgViewAlert = [[UIImageView alloc] initWithImage:image];
    [imgViewAlert setFrame:CGRectMake(20, 50, 230, 125)];
    [imgViewAlert setContentMode:UIViewContentModeScaleAspectFit];
    [alert.view addSubview:imgViewAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    cv::Mat gray_image;
    cv::cvtColor(image, gray_image, cv::COLOR_BGR2GRAY);
    cv::GaussianBlur(gray_image, gray_image, cv::Size(21, 21), 0);
    
    if (initalFrame.empty()) {
        initalFrame = gray_image;
    }
    
    [self imageStabalization:gray_image outputImage:image];
    cv::Rect frame;
    if ([self imageMotionTracking:gray_image outputImage:image frame:frame]) {
//        frame = cv::Rect(frame.x-20,frame.y-20,frame.width+20,frame.height+20);
//        cv::rectangle(image, frame, CVScalarFromUIColor([UIColor yellowColor]));
    }
    
    initalFrame = gray_image;    
}
@end
