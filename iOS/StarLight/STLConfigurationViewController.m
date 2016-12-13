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

#import <ChameleonFramework/Chameleon.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <GPUImage/GPUImage.h>

@interface STLConfigurationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate> {
    STLDesignView *drawView;
    UIImage *currentImage;
    
    NS2DArray *matrix;
}
@end

@implementation STLConfigurationViewController
static NSString * const reuseIdentifier = @"starlight.download.cell";
+ (BOOL)convertImage:(UIImage *)image toLightState:(NS2DArray *)matrix {
    if (image == nil) {
        for (NSInteger section = 0; section < matrix.sections; section++) {
            for (NSInteger row = 0; row < matrix.rows; row++) {
                [matrix setObject:[NSNumber numberWithBool:NO] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }        
        return NO;
    }
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageFilter *colorFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"TransparentToWhiteColor"];
    [stillImageSource addTarget:colorFilter];
    [colorFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    UIImage *imgColor = [colorFilter imageFromCurrentFramebuffer];
    
    CGSize cropSize = CGSizeMake(imgColor.size.width/matrix.sections, imgColor.size.height/matrix.rows);
    for (NSInteger section = 0; section < matrix.sections; section++) {
        for (NSInteger row = 0; row < matrix.rows; row++) {
            CGRect rect = CGRectMake(cropSize.width*section, cropSize.height*row, cropSize.width, cropSize.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([imgColor CGImage], rect);
            UIImage *imgCrop = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
            CGFloat alpha;
            [[UIColor colorWithAverageColorFromImage:imgCrop] getRed:nil green:nil blue:nil alpha:&alpha];
            BOOL isOn = (alpha > 0.5) ? YES : NO;
            [matrix setObject:[NSNumber numberWithBool:isOn] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }
    return YES;
}
- (instancetype)initWithHub:(id)hub withCurrentImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _hub = hub;
        currentImage = image;
        matrix = [NS2DArray arrayWithSections:10 rows:10];
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
    [drawView updateValuesForMatrixSize:CGSizeMake(matrix.sections, matrix.rows)];
    __weak typeof(self) weakSelf = self;
    drawView.didFinishDrawing = ^(UIImage *image){
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
    [STLConfigurationViewController convertImage:drawView.image toLightState:matrix];
    [self presentViewController:[[STLAdvancedViewController alloc] initWithMatrix:matrix] animated:YES completion:nil]; /* hub.matrix */
}

#pragma mark - Matrix Image
- (void)updateMatrixFromImage:(UIImage*)image {
    /* Convert iamge to matrix of points (int,int) (0 = off, 1 = on) save to coredata */
    
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
