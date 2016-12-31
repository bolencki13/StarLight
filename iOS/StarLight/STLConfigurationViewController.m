//
//  STLConfigurationViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//
//http://stackoverflow.com/questions/2342327/how-i-count-red-color-pixel-from-the-uiimage-using-objective-c-in-iphone/2344419#2344419

#import "STLConfigurationViewController.h"
#import "STLDesignView.h"
#import "STLDownloadCollectionViewCell.h"
#import "STLAdvancedViewController.h"
#import "NS2DArray.h"
#import "STLDataManager.h"
#import "STLHub.h"
#import "STLLight.h"
#import "STLLightPattern.h"

#import <ChameleonFramework/Chameleon.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface STLConfigurationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate> {
    STLDesignView *drawView;
    UIImage *currentImage;
    
    NS2DArray *matrix;
}
@end

@implementation STLConfigurationViewController
static NSString * const reuseIdentifier = @"starlight.download.cell";
+ (STLLightPattern*)lightPatternFromStates:(NS2DArray*)states {
    if (states == nil) {
        return nil;
    }
    STLLightPattern *pattern = [STLLightPattern pattern];
    
    for (NSInteger section = 0; section < states.sections; section++) {
        for (NSInteger row = 0; row < states.rows; row++) {
            
        }
    }
    
    return pattern;
}
- (instancetype)initWithHub:(STLHub*)hub withCurrentImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _hub = hub;
        currentImage = image;
        matrix = [hub lightMatrix];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    self.navigationController.hidesNavigationBarHairline = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    UIView *viewExtendNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame)+8)];
    viewExtendNavBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
    [self.view addSubview:viewExtendNavBar];
    
    drawView = [[STLDesignView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.view.frame)-20, CGRectGetWidth(self.view.frame)-20)withImage:currentImage];
    [drawView updateValuesForMatrixSize:CGSizeMake(matrix.rows, matrix.sections)];
    __weak typeof(self) weakSelf = self;
    drawView.didFinishDrawing = ^(UIImage *image, NS2DArray *states){
        weakSelf.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:weakSelf action:@selector(exit)];
        weakSelf.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:weakSelf action:@selector(saveAndExit)];
    };
    [self.view addSubview:drawView];
  
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [flowLayout setSectionInset:UIEdgeInsetsMake(10,10,10,10)];
    [flowLayout setItemSize:CGSizeMake(80, 110)];
    [flowLayout setMinimumInteritemSpacing:10];
    [flowLayout setMinimumLineSpacing:10];
    
    UICollectionView *clvDownloads = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(drawView.frame), CGRectGetWidth(self.view.frame), 130) collectionViewLayout:flowLayout];
    clvDownloads.dataSource = self;
    clvDownloads.delegate = self;
    clvDownloads.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    [clvDownloads registerClass:[STLDownloadCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    clvDownloads.emptyDataSetSource = self;
    clvDownloads.emptyDataSetDelegate = self;
    [self.view addSubview:clvDownloads];
    
    UIButton *btnErase = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnErase setFrame:CGRectMake(15, CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.navigationController.navigationBar.frame)*2-40, (CGRectGetWidth(self.view.frame)-34)/3, 40)];
    [btnErase setTitle:@"Erase" forState:UIControlStateNormal];
    [btnErase setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnErase setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    [btnErase addTarget:drawView action:@selector(erase) forControlEvents:UIControlEventTouchUpInside];
    btnErase.layer.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    btnErase.layer.shadowOpacity = 0.3;
    btnErase.layer.shadowRadius = 8.0;
    btnErase.layer.shadowOffset = CGSizeZero;
    [self.view addSubview:btnErase];
    [clvDownloads setFrame:CGRectMake(0, CGRectGetMaxY(drawView.frame)+((CGRectGetMinY(btnErase.frame)-CGRectGetMaxY(drawView.frame))-CGRectGetHeight(clvDownloads.frame))/2, CGRectGetWidth(self.view.frame), CGRectGetHeight(clvDownloads.frame))];
    
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRoundedRect:btnErase.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerTopLeft) cornerRadii:CGSizeMake(CGRectGetHeight(btnErase.frame)/2, CGRectGetHeight(btnErase.frame)/2)];
    CAShapeLayer *leftMask = [CAShapeLayer layer];
    leftMask.frame = btnErase.bounds;
    leftMask.path = leftPath.CGPath;
    btnErase.layer.mask = leftMask;
    
    UIButton *btnPreview = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPreview setFrame:CGRectMake(CGRectGetMaxX(btnErase.frame)+2, CGRectGetMinY(btnErase.frame), CGRectGetWidth(btnErase.frame), CGRectGetHeight(btnErase.frame))];
    [btnPreview setTitle:@"Preview" forState:UIControlStateNormal];
    [btnPreview setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPreview setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    [btnPreview addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
    btnPreview.layer.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    btnPreview.layer.shadowOpacity = 0.3;
    btnPreview.layer.shadowRadius = 8.0;
    btnPreview.layer.shadowOffset = CGSizeZero;
    [self.view addSubview:btnPreview];

    UIButton *btnAdvanced = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAdvanced setFrame:CGRectMake(CGRectGetMaxX(btnPreview.frame)+2, CGRectGetMinY(btnPreview.frame), CGRectGetWidth(btnPreview.frame), CGRectGetHeight(btnPreview.frame))];
    [btnAdvanced setTitle:@"Advanced" forState:UIControlStateNormal];
    [btnAdvanced setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnAdvanced setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    [btnAdvanced addTarget:self action:@selector(advanced) forControlEvents:UIControlEventTouchUpInside];
    btnAdvanced.layer.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    btnAdvanced.layer.shadowOpacity = 0.3;
    btnAdvanced.layer.shadowRadius = 8.0;
    btnAdvanced.layer.shadowOffset = CGSizeZero;
    [self.view addSubview:btnAdvanced];
    
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRoundedRect:btnErase.bounds byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerTopRight) cornerRadii:CGSizeMake(CGRectGetHeight(btnAdvanced.frame)/2, CGRectGetHeight(btnAdvanced.frame)/2)];
    CAShapeLayer *rightMask = [CAShapeLayer layer];
    rightMask.frame = btnErase.bounds;
    rightMask.path = rightPath.CGPath;
    btnAdvanced.layer.mask = rightMask;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)saveAndExit {
    [self updateMatrixFromImage:drawView.image];
    [self exit];
}
- (void)exit {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)preview {
    
}
- (void)advanced {
    UIViewController *viewController = nil;
    @try {
        viewController = [[STLAdvancedViewController alloc] initWithLightsMatrix:matrix withLightState:drawView.states];
    } @catch (NSException *exception) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"StarLight" message:@"An internal error occured. Please try again." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
        viewController = alert;
    } @finally {
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

#pragma mark - Matrix Image
- (void)updateMatrixFromImage:(UIImage*)image {
    /* Convert image to matrix of points (int,int) (0 = off, 1 = on) save to coredata */
    
    [_delegate configurationViewController:self didFinishWithImage:image];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STLDownloadCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.previewImage.image = currentImage;
    cell.titleLabel.text = @"Title Goes Here";
    cell.titleLabel.adjustsFontSizeToFitWidth = YES;
    cell.titleLabel.minimumScaleFactor = 0.7;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
@end
