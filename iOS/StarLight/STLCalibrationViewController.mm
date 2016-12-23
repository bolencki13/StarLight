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

#import <ChameleonFramework/Chameleon.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "BEMCheckBox.h"
#import <GPUImage/GPUImage.h>
#import <OpenCV/opencv2/opencv.hpp>
#import <OpenCV/opencv2/imgcodecs/ios.h>
#import <OpenCV/opencv2/videoio/cap_ios.h>

#define LIGHTS_PER_STRAND (25)
#define DELAY (0.3)
#define OFFSET (16)

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

@interface STLCalibrationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, CvVideoCameraDelegate, BEMCheckBoxDelegate> {
    UICollectionView *clvLights; // collection view used for confirmation
    UIImageView *imgViewCalibration; // imageview used for preview shown to user
    
    NSInteger strands; // number of strands input by user
    
    CvVideoCamera *camera; // camera used for calibration
    UIImage *imgCalibration; // image stored to be shown in 'imgViewCalibration'
    
    NSMutableArray *aryCoordinates; // coordinates or 'CGRect' of light positions
    NSInteger frames; // number of frames used
    
    NS2DArray *ary2DLights; // stored 2D array of light coordinates
    NSMutableDictionary *dictPositionIndexes; // key value pair of index and position (key=>'light.index' : value=>'position')
    NSInteger positionLightsOn; // seconds will not be accurate this is to keep track of now many lights should be on
    NSInteger lightsActual; // actual amount of lights found
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

    if ([GPUImageVideoCamera isBackFacingCameraPresent]) {
        aryCoordinates = [NSMutableArray new];

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
//            XXX: Should probably turn lights off first (zero them) unable to do so due to time constraint with bean
//            [self turnLightsOn:NO];
            [self turnLightsOn:YES withDelay:DELAY]; // turning on here due to time constraint
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

#pragma mark - Lights
- (void)turnLightsOn:(BOOL)on withDelay:(NSTimeInterval)time {
    if (on) {
        for (NSInteger x = OFFSET; x < [self calculatedLights]+OFFSET; x++) {
            [NSThread sleepForTimeInterval:time];
            [[STLSequenceManager sharedManager] setLightAtPosition:x toColor:[UIColor redColor]];
        }
    } else {
        for (NSInteger x = OFFSET; x < [self calculatedLights]+OFFSET; x++) {
            [NSThread sleepForTimeInterval:time];
            [[STLSequenceManager sharedManager] setLightAtPosition:x on:NO];
        }
    }
}

#pragma mark - Calibration
- (void)startCalibration {
//    XXX: Should really turn lights on here but can't due to time constraint (scan for 5 seconds; takes (0.3*25*strands)(7.5seconds * strands) to turn on)
//    [self turnLightsOn:NO];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exit)];
    _calibrating = YES;
    _positioning = NO;
    frames = 0;
    imgCalibration = NULL;
    [aryCoordinates removeAllObjects];
    aryCoordinates = [NSMutableArray new];
    [self cameraResetProperties];
}
- (void)confirmCalibration {
    if (!imgCalibration) return;
    
    [self turnLightsOn:NO withDelay:DELAY];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(positionCalibration)];
    [camera stop];
    imgViewCalibration.image = imgCalibration;
    imgViewCalibration.contentMode = UIViewContentModeScaleAspectFit;
    
    for (NSInteger x = 0; x < [aryCoordinates count]; x++) {
        CGRect frame = [[aryCoordinates objectAtIndex:x] CGRectValue];
        
        BEMCheckBox *checkBox = [[BEMCheckBox alloc] initWithFrame:frame];
        [checkBox setOn:YES animated:NO];
        checkBox.delegate = self;
        checkBox.tag = 10+x;
        [imgViewCalibration addSubview:checkBox];
    }
    
    [clvLights reloadData];
}
- (void)positionCalibration {
    NSMutableArray *aryTemp = [NSMutableArray new];
    for (NSInteger x = 0; x < [aryCoordinates count]; x++) {
        BEMCheckBox *checkBox = (BEMCheckBox*)[imgViewCalibration viewWithTag:10+x];
        if (checkBox.on) {
            [aryTemp addObject:[NSValue valueWithCGRect:checkBox.frame]];
        }
    }
    lightsActual = [aryTemp count];

    ary2DLights = [NS2DArray arrayFromCoordinates:aryTemp];
    dictPositionIndexes = [NSMutableDictionary new];
    
    [camera start];
    _calibrating = NO;
    _positioning = YES;
    
    dispatch_async(dispatch_queue_create("com.bolencki13.starlight.calibratePosition", 0), ^(void){
        positionLightsOn = 0;
        for (NSInteger x = OFFSET; x < [self calculatedLights]+OFFSET; x++) {
            [NSThread sleepForTimeInterval:1];
            [[STLSequenceManager sharedManager] setLightAtPosition:x toColor:[UIColor redColor]];
            positionLightsOn++;
        }
    });
}
- (void)finishCalibration {
    [camera stop];
    [self turnLightsOn:NO withDelay:DELAY];;
    
    NSError *error = nil;
    STLHub *hub = [[STLDataManager sharedManager] registerHubWithLights:ary2DLights withPositions:dictPositionIndexes];
    hub.name = self.title;
    
    [[STLDataManager sharedManager] saveData:&error];
    if (error) {
        [self errorWithMessage:@"An error occured during the calibration sequence. Please try again."];
    } else {
        [self exit];
    }
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
- (BOOL)isPossibleLightFrame:(cv::Rect)next estimatedLightFrame:(cv::Rect)frame withErrorPercent:(CGFloat)errMargin {
    if (next.width < (frame.width*(1.0-errMargin)) || next.width > (frame.width*(1.0+errMargin))) {
        return NO;
    } else if (next.height < (frame.height*(1.0-errMargin)) || next.height > (frame.height*(1.0+errMargin))) {
        return NO;
    }
    return YES;
}
- (CGFloat)distanceFromRect:(CGRect)rect1 to:(CGRect)rect2 {
    CGPoint center1 = CGPointMake(CGRectGetMidX(rect1), CGRectGetMidY(rect1));
    CGPoint center2 = CGPointMake(CGRectGetMidX(rect2), CGRectGetMidY(rect2));
    
    double dx = (center2.x-center1.x);
    double dy = (center2.y-center1.y);
    double dist = sqrt(dx*dx + dy*dy);
    
    return dist;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [aryCoordinates count];
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
    cv::Mat matColor;
    cv::inRange(matHSV, cv::Scalar(0,0,230), cv::Scalar(150,150,255), matColor);
    
    // helps remove noise
    cv::Mat erodeElement = getStructuringElement(cv::MORPH_ELLIPSE,cv::Size(2,2));
    cv::Mat dilateElement = getStructuringElement(cv::MORPH_ELLIPSE,cv::Size(2,2));
    erode(matColor,matColor,erodeElement);
    dilate(matColor,matColor,dilateElement);
    
    // converts image to binary for analysis
    cv::Mat matBinary;
    cv::threshold(matColor, matBinary, 0, 255, cv::THRESH_BINARY);
    
    cv::GaussianBlur(matBinary, matBinary, cv::Size(9, 9), 2, 2); // applies blur to even out image and remove jaggedness
    
    // helps remove even more noise
    erode(matBinary,matBinary,erodeElement);
    dilate(matBinary,matBinary,dilateElement);
    
    cv::GaussianBlur(matBinary, matBinary, cv::Size(9, 9), 2, 2); // applies blur to even out image and remove jaggedness
    
    // counts connected components in binary image
    cv::Mat labels, stats, centroids;
    NSInteger count = connectedComponentsWithStats(matBinary, labels, stats, centroids, 8, CV_32S);

    if (_calibrating && frames <= 150) {
        // converts current frame to RGB for UIImage manipulation
        cv::Mat matRGB;
        cv::cvtColor(image, matRGB, cv::COLOR_BGR2RGB);
        cv::transpose(matRGB,matRGB);
        cv::flip(matRGB,matRGB,0);
        
        // loops through frames checking if the frame is close to our estimated frame
        [aryCoordinates removeAllObjects];
        for (int x = 1; x < count; x++) {
            cv::Rect frame(cv::Point(stats.at<int>(x,cv::CC_STAT_LEFT),stats.at<int>(x,cv::CC_STAT_TOP)), cv::Point(stats.at<int>(x,cv::CC_STAT_LEFT)+stats.at<int>(x,cv::CC_STAT_WIDTH),stats.at<int>(x,cv::CC_STAT_TOP)+stats.at<int>(x,cv::CC_STAT_HEIGHT))); // Current frame of 'light'
            cv::rectangle(image, frame.tl(), frame.br(), CVScalarFromUIColor([UIColor blueColor]), 2, CV_AA);
            [aryCoordinates addObject:[NSValue valueWithCGRect:CGRectMake((frame.y*CGRectGetWidth(imgViewCalibration.frame))/matRGB.cols, CGRectGetHeight(imgViewCalibration.frame)-CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)/2-(frame.x*CGRectGetHeight(imgViewCalibration.frame))/matRGB.rows, frame.width, frame.height)]]; // frame qualifies, add to array of light positions; apparently opencv does (y,x) must be switched for everything else (🖕🏼)
        }
        
        // (150) => approximately 5 seconds
        if (frames == 150) {
            imgCalibration = MatToUIImage(matRGB);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Lights Found!" message:[NSString stringWithFormat:@"We have found %lu of %ld lights. Would you like to continue?",(unsigned long)[aryCoordinates count],(long)[self calculatedLights]] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self exit];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Let's go!" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self confirmCalibration];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Re-scan" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self startCalibration];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        frames++;
    } else if (_positioning) {
        NSInteger currentLightCount = count-1;
        if ([[dictPositionIndexes allKeys] count] < currentLightCount && currentLightCount <= positionLightsOn) {
            __block NSInteger counter = 0;
            __block NSNumber *index = nil;
            [ary2DLights enumerateObjectsUsingBlock:^(NSNumber *obj, NSIndexPath *indexPath, BOOL *stop) {
                if ([obj integerValue] != -1) {
                    if (counter == currentLightCount) {
                        index = obj;
                        *stop = YES;
                    }
                    counter++;
                }
            }];
            if (index) {
                [dictPositionIndexes setObject:[NSNumber numberWithInteger:currentLightCount] forKey:[NSString stringWithFormat:@"%li",[index integerValue]]]; // error because opencv starts from bottom left always. Will not follow lights directly
                // if a light was not found curing initial calibration then it is not skipped here rather it is lost from the end (could result in another dropped light)
                NSLog(@"%@",dictPositionIndexes);
            }
            if (currentLightCount >=  lightsActual || positionLightsOn >= lightsActual) {
                [self finishCalibration];
            }
        }
    }
}

#pragma mark - BEMCheckBoxDelegate
- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:checkBox.tag-10 inSection:0];
    ((STLCalibrationCollectionViewCell*)[clvLights cellForItemAtIndexPath:indexPath]).active = !((STLCalibrationCollectionViewCell*)[clvLights cellForItemAtIndexPath:indexPath]).active;
}
@end
