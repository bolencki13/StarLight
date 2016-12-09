//
//  STLCalibrationViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/8/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLCalibrationViewController.h"

#import <GPUImage/GPUImage.h>
#import <ChameleonFramework/Chameleon.h>

GPUVector3 GPUVector3FromUIColor(UIColor *color) {
    GPUVector3 vector;
    
    CGFloat red,green,blue,alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    vector.one = red;
    vector.two = green;
    vector.three = blue;
    
    return vector;
}

@interface STLCalibrationViewController () {
    GPUImageVideoCamera *_liveVideo;
    GPUImageView *_backgroundImageView;
    
    GPUImageRawDataOutput *videoRawData;

    GPUImageFilter *redFilter;
    GPUImageiOSBlurFilter *blurFilter;
    
    GPUImageUIElement *uiElementInput;
}
@end

@implementation STLCalibrationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    self.navigationController.hidesNavigationBarHairline = YES;
    
    UIView *viewExtendNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    viewExtendNavBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
    [self.view addSubview:viewExtendNavBar];

    if ([GPUImageVideoCamera isBackFacingCameraPresent]) {
        _backgroundImageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_backgroundImageView];
        
        _liveVideo = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetInputPriority cameraPosition:AVCaptureDevicePositionBack];
        _liveVideo.outputImageOrientation = UIInterfaceOrientationPortrait;
        
        redFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"RedColor"];
        
        blurFilter = [[GPUImageiOSBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 1.0;
        
        [_liveVideo addTarget:redFilter];
        [redFilter addTarget:_backgroundImageView];
        [blurFilter addTarget:_backgroundImageView];
        [_liveVideo addTarget:_backgroundImageView];
        
        [_liveVideo startCameraCapture];
    } else {
        NSString *text = @"Whoops!\nNo rear camera could be found";
        NSMutableAttributedString *astrText = [[NSMutableAttributedString alloc] initWithString:text];
        [astrText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]+26] range:[text rangeOfString:@"Whoops!"]];
        [astrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize]+8] range:[text rangeOfString:@"No rear camera could be found"]];
        [astrText addAttribute:NSForegroundColorAttributeName value:self.navigationController.navigationBar.barTintColor range:[text rangeOfString:text]];
        
        UILabel *lblInfo = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.frame)/2-50, CGRectGetWidth(self.view.frame)-40, 100)];
        lblInfo.attributedText = astrText;
        lblInfo.numberOfLines = 2;
        lblInfo.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lblInfo];
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
