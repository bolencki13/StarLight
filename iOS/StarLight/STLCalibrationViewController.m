//
//  STLCalibrationViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/8/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLCalibrationViewController.h"
#import "STLCalibrationCollectionViewCell.h"

#import <GPUImage/GPUImage.h>
#import <ChameleonFramework/Chameleon.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

GPUVector3 GPUVector3FromUIColor(UIColor *color) {
    GPUVector3 vector;
    
    CGFloat red,green,blue,alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    vector.one = red;
    vector.two = green;
    vector.three = blue;
    
    return vector;
}

@interface STLCalibrationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate> {
    UICollectionView *clvLights;
    
    GPUImageVideoCamera *_liveVideo;
    GPUImageView *_backgroundImageView;
    
    GPUImageRawDataOutput *videoRawData;

    GPUImageFilter *redFilter;
    GPUImageiOSBlurFilter *blurFilter;
    
    GPUImageUIElement *uiElementInput;
    
    NSMutableArray *aryLights;
}
@end

@implementation STLCalibrationViewController
static NSString * const reuseIdentifier = @"starlight.calibration.cell";
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    self.navigationController.hidesNavigationBarHairline = YES;
    
    UIView *viewExtendNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    viewExtendNavBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
    [self.view addSubview:viewExtendNavBar];

    if ([GPUImageVideoCamera isBackFacingCameraPresent]) {
        [self setUpCameraView];
        
        aryLights = [@[
                       
                       ] mutableCopy];
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
        lblInfo.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:lblInfo];
    }
}
- (void)setUpCameraView {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [flowLayout setSectionInset:UIEdgeInsetsMake(10,10,10,10)];
    [flowLayout setItemSize:CGSizeMake(80, 80)];
    [flowLayout setMinimumInteritemSpacing:10];
    [flowLayout setMinimumLineSpacing:10];

    clvLights = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.navigationController.navigationBar.frame)-120, CGRectGetWidth(self.view.frame), 100) collectionViewLayout:flowLayout];
    clvLights.dataSource = self;
    clvLights.delegate = self;
    clvLights.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    [clvLights registerClass:[STLCalibrationCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    clvLights.emptyDataSetSource = self;
    clvLights.emptyDataSetDelegate = self;
    [self.view addSubview:clvLights];
    
    _backgroundImageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.navigationController.navigationBar.frame)-120)];
    [self.view addSubview:_backgroundImageView];
    
    _liveVideo = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    _liveVideo.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    redFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"RedColor"];
    
    blurFilter = [[GPUImageiOSBlurFilter alloc] init];
    blurFilter.blurRadiusInPixels = 1.0;
    
    [_liveVideo addTarget:redFilter];
    [redFilter addTarget:_backgroundImageView];
    [blurFilter addTarget:_backgroundImageView];
    [_liveVideo addTarget:_backgroundImageView];
    
    [_liveVideo startCameraCapture];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [aryLights count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STLCalibrationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.numberOfLines = 2;
    cell.titleLabel.text = [NSString stringWithFormat:@"Light:\n#%ld",(long)indexPath.row+1];
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"No StarLights found";
    
    NSMutableAttributedString *astrText = [[NSMutableAttributedString alloc] initWithString:text];
    [astrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize]+8] range:[text rangeOfString:text]];
    [astrText addAttribute:NSForegroundColorAttributeName value:self.navigationController.navigationBar.barTintColor range:[text rangeOfString:text]];
    
    return astrText;
}
@end
