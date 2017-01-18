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
#import "STLPreviewViewController.h"
#import "NS2DArray.h"
#import "STLLightPattern.h"
#import "STLDataManager.h"
#import "STLHub.h"
#import "STLLight.h"
#import "STLLightPattern.h"

#import <ChameleonFramework/Chameleon.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface STLConfigurationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, STLAdvancedViewControllerDelegate> {
    STLDesignView *drawView;
    UIImage *currentImage;
    NS2DArray *currentStates;
    
    NS2DArray *matrix;
    
    UICollectionView *clvFrames;
    NSMutableArray *aryFrames;
}
@end

@implementation STLConfigurationViewController
static NSString * const reuseIdentifier = @"starlight.download.cell";
+ (STLLightPattern*)lightPatternFromStates:(NS2DArray*)states forHub:(STLHub*)hub {
    if (states == nil) {
        return nil;
    }
    STLLightPattern *pattern = [STLLightPattern patternForHub:hub];
    
    for (NSInteger section = 0; section < states.sections; section++) {
        for (NSInteger row = 0; row < states.rows; row++) {
            
        }
    }
    
    return pattern;
}
- (instancetype)initWithHub:(STLHub*)hub withCurrentImage:(UIImage *)image withStates:(NS2DArray *)states {
    self = [super init];
    if (self) {
        _hub = hub;
        currentImage = image;
        currentStates = states;
        matrix = [hub lightMatrix];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    self.navigationController.hidesNavigationBarHairline = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    aryFrames = [NSMutableArray new];
    
    UIView *viewExtendNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame)+8)];
    viewExtendNavBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
    [self.view addSubview:viewExtendNavBar];
    
    drawView = [[STLDesignView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.view.frame)-20, CGRectGetWidth(self.view.frame)-20) withImage:currentImage withHub:_hub withStates:currentStates];
    if (!currentStates) {
        [drawView updateValuesForMatrixSize:[NSIndexPath indexPathForRow:matrix.rows inSection:matrix.sections]];
    }
    __weak typeof(self) weakSelf = self;
    drawView.didFinishDrawing = ^(UIImage *image, NS2DArray *states, STLLightPattern *lightPattern){
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
    
    clvFrames = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(drawView.frame), CGRectGetWidth(self.view.frame), 130) collectionViewLayout:flowLayout];
    clvFrames.dataSource = self;
    clvFrames.delegate = self;
    clvFrames.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    [clvFrames registerClass:[STLDownloadCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    clvFrames.emptyDataSetSource = self;
    clvFrames.emptyDataSetDelegate = self;
    [self.view addSubview:clvFrames];
    
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
    [clvFrames setFrame:CGRectMake(0, CGRectGetMaxY(drawView.frame)+((CGRectGetMinY(btnErase.frame)-CGRectGetMaxY(drawView.frame))-CGRectGetHeight(clvFrames.frame))/2, CGRectGetWidth(self.view.frame), CGRectGetHeight(clvFrames.frame))];
    
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
    [_delegate configurationViewController:self didFinishWithImage:drawView.image states:drawView.states];
    [self exit];
}
- (void)exit {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)preview {
    NSMutableArray *aryImages = [NSMutableArray new];
    for (NSDictionary *dict in aryFrames) {
        [aryImages addObject:[dict objectForKey:@"image"]];
    }
    [self presentViewController:[[STLPreviewViewController alloc] initWithImages:aryImages animationDuration:1.0] animated:YES completion:nil];
}
- (void)advanced {
    UIViewController *viewController = nil;
    @try {
        viewController = [[STLAdvancedViewController alloc] initWithLightsMatrix:matrix withLightState:drawView.states];
        ((STLAdvancedViewController*)viewController).delegate = self;
    } @catch (NSException *exception) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"StarLight" message:@"An internal error occured. Please try again." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
        viewController = alert;
    } @finally {
        [self presentViewController:viewController animated:YES completion:nil];
    }
}
- (void)newFrame {
    if ([aryFrames count] == 20) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Whoops!" message:@"The max number of frames as been met." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (!drawView.image) return;
    [aryFrames addObject:@{
                           @"image" : drawView.image,
                           @"states" : drawView.states,
                           }];
    
    [clvFrames performBatchUpdates:^{
        [clvFrames insertItemsAtIndexPaths:@[
                                             [NSIndexPath indexPathForRow:[aryFrames count]-1 inSection:0],
                                             ]];
    } completion:^(BOOL finished) {
        [clvFrames scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[aryFrames count] inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [aryFrames count]+1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STLDownloadCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (indexPath.row < [aryFrames count]) {
        cell.previewImage.image = [[aryFrames objectAtIndex:indexPath.row] objectForKey:@"image"];
        cell.previewImage.contentMode = UIViewContentModeScaleAspectFit;
        cell.titleLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    } else {
        UIImage *imgPlus = [UIImage imageNamed:@"Plus"];
        UIImage *imgPlusTint = [imgPlus imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(imgPlus.size, NO, imgPlus.scale);
        [cell.titleLabel.textColor set];
        [imgPlusTint drawInRect:CGRectMake(0, 0, imgPlus.size.width, imgPlus.size.height)];
        imgPlusTint = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cell.previewImage.image = imgPlusTint;
        cell.previewImage.contentMode = UIViewContentModeCenter;
        cell.titleLabel.text = @"New Frame";
    }
    cell.titleLabel.adjustsFontSizeToFitWidth = YES;
    cell.titleLabel.minimumScaleFactor = 0.6;

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [aryFrames count]) {
        
    } else {
        [self newFrame];
    }
}

#pragma mark - STLAdvancedViewControllerDelegate
- (void)configurationViewController:(STLAdvancedViewController *)viewController didFinishWithStates:(NS2DArray *)states {
    NS2DArray *aryTemp = [[NS2DArray alloc] initWith2DArray:states]; // for some reason after erase 'states' is reset as well 🤔
    [drawView erase];

    [aryTemp enumerateObjectsUsingBlock:^(id obj, NSIndexPath *indexPath, BOOL *stop) {
        if ([obj boolValue] == YES) {
            [drawView highlightAtIndex:indexPath];
        }
    }];
}
@end
