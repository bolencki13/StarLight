//
//  STLCalibrationViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/8/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLCalibrationViewController.h"
#import "STLCalibrationCollectionViewCell.h"
#import "UIAlertController+UIImage.h"
#import "STLAppDelegate.h"
#import "STLDataManager.h"
#import "STLBluetoothManager.h"
#import "STLSequenceManager.h"
#import "NS2DArray+CGRect.h"
#import "AVCaptureDevice+DevicePresence.h"
#import "STLLightPattern.h"
#import "STLLightFrame.h"

#import <ChameleonFramework/Chameleon.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <BEMCheckBox.h>
#import <OpenCV/opencv2/opencv.hpp>
#import <OpenCV/opencv2/imgcodecs/ios.h>
#import <OpenCV/opencv2/videoio/cap_ios.h>

#define LIGHTS_PER_STRAND (4)
#define OFFSET (0)

UIColor *UIColorFromCVScalar(cv::Scalar color) {
    return [UIColor colorWithRed:color[0]/255 green:color[1]/255 blue:color[2]/255 alpha:1.0];
}
cv::Scalar CVScalarFromUIColor(UIColor *color) {
    CGFloat red,green,blue;
    [color getRed:&red green:&green blue:&blue alpha:nil];
    return cv::Scalar(blue*255, green*255, red*255);
}
cv::Rect RectFromCGRrect(CGRect frame) {
    return cv::Rect(frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
}
CGRect CGRectFromRect(cv::Rect frame) {
    return CGRectMake(frame.x, frame.y, frame.width, frame.height);
}

NSNotificationName kSTLCalibrationDidFinish = @"STLCalibrationDidFinish";

@interface STLCalibrationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, CvVideoCameraDelegate, BEMCheckBoxDelegate> {
    UICollectionView *clvLights; // collection view used for confirmation
    UIImageView *imgViewCalibration; // imageview used for preview shown to user
    
    NSInteger strands; // number of strands input by user
    
    CvVideoCamera *camera; // camera used for calibration
    cv::Mat matCalibration; // mat stored to be shown in 'imgViewCalibration'
    
    NSMutableDictionary *dictLights; // dictionary to store light position relative light index
    NSInteger frames; // frames scanned
    NSInteger currentLight; // current light being tracked
}
@end

@implementation STLCalibrationViewController
static NSString * const reuseIdentifier = @"starlight.calibration.cell";
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    self.navigationController.hidesNavigationBarHairline = YES;
    
    _calibrating = NO;
    self.title = _peripheral.name;
    
    UIView *viewExtendNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    viewExtendNavBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
    [self.view addSubview:viewExtendNavBar];
    
    if ([AVCaptureDevice supportsDeviceType:AVCaptureDevicePositionBack]) {
        
        
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
        
        imgViewCalibration = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.navigationController.navigationBar.frame)-120)];
        imgViewCalibration.userInteractionEnabled = YES;
        [self.view addSubview:imgViewCalibration];
        
        [self setUpCameraView];
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
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"StarLight" message:@"How many strands of lights?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"# of strands";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Start Calibration" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        strands = [[alert.textFields objectAtIndex:0].text integerValue];
        if (strands < 1) {
            [self exit];
        } else {
            [self startCalibration];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self exit];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)setUpCameraView {
    camera = [[CvVideoCamera alloc] initWithParentView:imgViewCalibration];
    camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
    camera.defaultFPS = 30;
    camera.delegate = self;
    camera.rotateVideo = YES;
    [camera adjustLayoutToInterfaceOrientation:UIInterfaceOrientationPortrait];
    [camera start];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)exit {
    [[STLBluetoothManager sharedManager] disconnnectFromPeripheral:self.peripheral];
    [camera stop];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Camera
- (void)cameraResetProperties {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device lockForConfiguration:nil]) {
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            else [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) [device setExposureMode:AVCaptureExposureModeAutoExpose];
            else [device setExposureMode:AVCaptureExposureModeLocked];
            [device unlockForConfiguration];
        }
    }
}

#pragma mark - Calibration
- (void)startCalibration {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exit)];
    
    matCalibration = NULL;
    
    for (NSInteger x = OFFSET; x < [self calculatedLights]+OFFSET; x++) {
        [NSThread sleepForTimeInterval:DELAY_BLE];
        if (x == OFFSET) {
            [[STLSequenceManager sharedManager] setLightAtPosition:x toColor:[UIColor greenColor]];
        } else {
            [[STLSequenceManager sharedManager] setLightAtPosition:x toColor:[UIColor redColor]];
        }
    }
    
    frames = 0;
    currentLight = 0;
    dictLights = [NSMutableDictionary new];
    
    [self cameraResetProperties];
    _calibrating = YES;
}
- (void)confirmCalibration {
    _calibrating = NO;
    [camera stop];
    
    imgViewCalibration.image = MatToUIImage(matCalibration);
    
    for (NSInteger x = 0; x < [[dictLights allKeys] count]; x++) {
        BEMCheckBox *checkBox = [[BEMCheckBox alloc] initWithFrame:[[dictLights objectForKey:[NSString stringWithFormat:@"%ld",(long)x]] CGRectValue]];
        [checkBox setOn:YES animated:NO];
        checkBox.delegate = self;
        checkBox.tag = 10+x;
        [imgViewCalibration addSubview:checkBox];
    }
    [clvLights reloadData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(exitCalibration)];
}
- (void)exitCalibration {
    NSMutableArray *aryCoordinates = [NSMutableArray new];
    for (NSInteger x = 0; x < [[dictLights allKeys] count]; x++) {
        [aryCoordinates addObject:[dictLights objectForKey:[NSString stringWithFormat:@"%ld",(long)x]]];
    }
    
    NSArray *aryX = [aryCoordinates sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        CGRect rect1 = [obj1 CGRectValue];
        CGRect rect2 = [obj2 CGRectValue];
        
        if (CGRectGetMinX(rect1) > CGRectGetMinX(rect2)) {
            return NSOrderedDescending;
        } else if (CGRectGetMinX(rect1) < CGRectGetMinX(rect2)) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    NSArray *aryY = [aryCoordinates sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        CGRect rect1 = [obj1 CGRectValue];
        CGRect rect2 = [obj2 CGRectValue];
        
        if (CGRectGetMinY(rect1) > CGRectGetMinY(rect2)) {
            return NSOrderedDescending;
        } else if (CGRectGetMinY(rect1) < CGRectGetMinY(rect2)) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    NSMutableDictionary *dictPositions = [NSMutableDictionary new];
    for (NSInteger section = 0; section < [aryCoordinates count]; section++) {
        CGRect rectX = [[aryX objectAtIndex:section] CGRectValue];
        for (NSInteger row = 0; row < [aryCoordinates count]; row++) {
            CGRect rectY = [[aryY objectAtIndex:row] CGRectValue];
            if (CGRectEqualToRect(rectX, rectY)) {
                [dictPositions setObject:[NSNumber numberWithInteger:(section*([aryCoordinates count]))+row] forKey:[NSString stringWithFormat:@"%@",NSStringFromCGRect(rectX)]];
                break;
            }
        }
    }
    
    NSMutableSet *setLights = [NSMutableSet new];
    for (NSInteger index = 0; index < [aryCoordinates count]; index++) {
        CGRect rect = [[aryCoordinates objectAtIndex:index] CGRectValue];
        NSInteger position = [[dictPositions objectForKey:[NSString stringWithFormat:@"%@",NSStringFromCGRect(rect)]] integerValue];
        
        STLLight *light = [STLLight light];
        light.index = index;
        light.position = position;
        light.on = NO;
        [setLights addObject:light];
    }
    __block STLHub *hub = [STLHub hubWithLights:setLights];
    hub.matrix = [NSIndexPath indexPathForRow:[aryCoordinates count] inSection:[aryCoordinates count]];
    hub.identifer = [self.peripheral.identifier UUIDString];
    
    STLLightFrame *frame = [STLLightFrame frameWithHub:hub];
    [frame setStateForLight:^BOOL(STLLight *light) {
        return NO;
    }];
    [frame reloadFrame];
    hub.pattern = [STLLightPattern patternWithFrames:@[
                                                       frame
                                                       ]];
    
    UIAlertController *alertName = [UIAlertController alertControllerWithTitle:@"StarLight" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertName addAction:[UIAlertAction actionWithTitle:@"Next" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        hub.name = [[alertName textFields] objectAtIndex:0].text;
        if ([hub.name isEqualToString:@""]) {
            hub.name = @"StarLight";
        }
        
        UIAlertController *alertLocation = [UIAlertController alertControllerWithTitle:@"StarLight" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertLocation addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            hub.location = [[alertLocation textFields] objectAtIndex:0].text;
            if ([hub.location isEqualToString:@""]) {
                hub.location = @"Unknown";
            }
            [_delgate calibrationdidFinish:self withHub:hub];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSTLCalibrationDidFinish object:hub userInfo:nil];
            [self exit];
        }]];
        [alertLocation addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Location";
        }];
        [self presentViewController:alertLocation animated:YES completion:nil];
    }]];
    [alertName addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Name";
    }];
    [self presentViewController:alertName animated:YES completion:nil];
}
- (void)errorWithMessage:(NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Uh, Oh" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Other
- (NSInteger)calculatedLights {
    return strands * LIGHTS_PER_STRAND;
}
- (CGFloat)distanceBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
    double dx = (p2.x-p1.x);
    double dy = (p2.y-p1.y);
    double dist = dx*dx + dy*dy;
    return dist;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[dictLights allKeys] count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STLCalibrationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.numberOfLines = 2;
    cell.titleLabel.text = [NSString stringWithFormat:@"Light:\n#%ld",(long)indexPath.row+1];
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BEMCheckBox *checkBox = (BEMCheckBox*)[imgViewCalibration viewWithTag:10+indexPath.row];
    [UIView animateWithDuration:0.25 animations:^{
        checkBox.transform = CGAffineTransformMakeScale(1.5,1.5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            checkBox.transform = CGAffineTransformMakeScale(1.0,1.0);
        }];
    }];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"No StarLights found";
    
    NSMutableAttributedString *astrText = [[NSMutableAttributedString alloc] initWithString:text];
    [astrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize]+8] range:[text rangeOfString:text]];
    [astrText addAttribute:NSForegroundColorAttributeName value:self.navigationController.navigationBar.barTintColor range:[text rangeOfString:text]];
    
    return astrText;
}

#pragma mark - CvVideoCameraDelegate
- (void)processImage:(cv::Mat &)image {
    cv::Mat matHSV;
    cv::cvtColor(image, matHSV, cv::COLOR_BGR2HSV); // converts image from bgr to hsv (easier to get certain colors from)
    
    // finds colors in range of specified value (blue, green, red) (default red)
    cv::Mat matRedColor;
    cv::inRange(matHSV, cv::Scalar(0,0,230), cv::Scalar(150,150,255), matRedColor);
    
    // helps remove noise
    cv::Mat erodeElement = getStructuringElement(cv::MORPH_ELLIPSE,cv::Size(2,2));
    cv::Mat dilateElement = getStructuringElement(cv::MORPH_ELLIPSE,cv::Size(2,2));
    erode(matRedColor,matRedColor,erodeElement);
    dilate(matRedColor,matRedColor,dilateElement);
    
    // converts image to binary for analysis
    cv::Mat matBinary;
    cv::threshold(matRedColor, matBinary, 0, 255, cv::THRESH_BINARY);
    
    cv::GaussianBlur(matRedColor, matBinary, cv::Size(9, 9), 2, 2); // applies blur to even out image and remove jaggedness
    
    // helps remove even more noise
    erode(matBinary,matBinary,erodeElement);
    dilate(matBinary,matBinary,dilateElement);
    
    cv::GaussianBlur(matBinary, matBinary, cv::Size(9, 9), 2, 2); // applies blur to even out image and remove jaggedness
    
    // counts connected components in binary image
    cv::Mat labels, stats, centroids;
    NSInteger count = connectedComponentsWithStats(matBinary, labels, stats, centroids, 8, CV_32S);
    
    if (_calibrating) {
        // converts current frame to RGB for UIImage manipulation
        cv::Mat matRGB;
        cv::cvtColor(image, matRGB, cv::COLOR_BGR2RGB);
        cv::transpose(matRGB,matRGB);
        cv::flip(matRGB,matRGB,0);
        
        for (int x = 1; x < count; x++) {
            cv::Rect frame(cv::Point(stats.at<int>(x,cv::CC_STAT_LEFT),stats.at<int>(x,cv::CC_STAT_TOP)), cv::Point(stats.at<int>(x,cv::CC_STAT_LEFT)+stats.at<int>(x,cv::CC_STAT_WIDTH),stats.at<int>(x,cv::CC_STAT_TOP)+stats.at<int>(x,cv::CC_STAT_HEIGHT)));
            cv::Mat1b mask(image.rows, image.cols, uchar(0));
            
            cv::Point pts[1][4];
            pts[0][0] = cv::Point(frame.tl().x,frame.tl().y);
            pts[0][1] = cv::Point(frame.tl().x, frame.tl().y+frame.height);
            pts[0][2] = cv::Point(frame.tl().x+frame.width, frame.tl().y+frame.height);
            pts[0][3] = cv::Point(frame.tl().x+frame.width,frame.tl().y);
            const cv::Point *points[1] = {pts[0]};
            int npoints = 4;
            cv::fillPoly(mask, points, &npoints, 1, cv::Scalar(255));
            cv::Scalar avgColor = mean(image, mask);

            int green = avgColor[1];
            int red = avgColor[2];
            
            if (green > red) {
                cv::rectangle(image, frame.tl(), frame.br(), CVScalarFromUIColor([UIColor blueColor]), 2, CV_AA);
                
                if (frames > 60) {
                    [dictLights setObject:[NSValue valueWithCGRect:CGRectMake((frame.y*CGRectGetWidth(imgViewCalibration.frame))/matRGB.cols, CGRectGetHeight(imgViewCalibration.frame)-CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)/2-(frame.x*CGRectGetHeight(imgViewCalibration.frame))/matRGB.rows, frame.width, frame.height)] forKey:[NSString stringWithFormat:@"%lu",(unsigned long)[[dictLights allKeys] count]]];
                    
                    [[STLSequenceManager sharedManager] setLightAtPosition:currentLight+OFFSET toColor:[UIColor redColor]];
                    [NSThread sleepForTimeInterval:DELAY_BLE];
                    currentLight++;
                    [[STLSequenceManager sharedManager] setLightAtPosition:currentLight+OFFSET toColor:[UIColor greenColor]];
                    frames = 0;
                    
                    if (currentLight >= [self calculatedLights]) {
                        matCalibration = matRGB;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self confirmCalibration];
                        });
                    }
                }
            } else {
                if (frames > 61) {
                    [[STLSequenceManager sharedManager] setLightAtPosition:currentLight+OFFSET toColor:[UIColor redColor]];
                    [NSThread sleepForTimeInterval:DELAY_BLE];
                    currentLight++;
                    [[STLSequenceManager sharedManager] setLightAtPosition:currentLight+OFFSET toColor:[UIColor greenColor]];
                    frames = 0;

                    if (currentLight >= [self calculatedLights]) {
                        matCalibration = matRGB;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self confirmCalibration];
                        });
                    }
                }
            }
        }
        frames++;
    }
}

#pragma mark - BEMCheckBoxDelegate
- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:checkBox.tag-10 inSection:0];
    ((STLCalibrationCollectionViewCell*)[clvLights cellForItemAtIndexPath:indexPath]).active = !((STLCalibrationCollectionViewCell*)[clvLights cellForItemAtIndexPath:indexPath]).active;
}
@end
