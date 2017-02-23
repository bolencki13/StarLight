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
#import "STLLightPattern.h"
#import "STLDataManager.h"
#import "STLHub.h"
#import "STLLight.h"
#import "STLLightFrame.h"
#import "STLStepper.h"
#import "STLColorPicker.h"
#import "UIColor+Image.h"
#import "UIImage+Size.h"
#import "NS2DArray.h"

#import <Chameleon.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface STLConfigurationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, STLAdvancedViewControllerDelegate> {
    STLDesignView *drawView;
    
    NS2DArray *matrix;
    
    UICollectionView *clvFrames;
    NSMutableArray *aryFrames;
    STLStepper *stpDelay;
    STLDownloadCollectionViewCell *btnColorPicker;
    STLColorPicker *colorPicker;
}
@end

@implementation STLConfigurationViewController
static NSString * const reuseIdentifier = @"starlight.download.cell";
- (instancetype)initWithPattern:(STLLightPattern *)pattern {
    self = [super init];
    if (self) {
        _pattern = pattern;
        matrix = [self.pattern.hub lightMatrix];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    self.navigationController.hidesNavigationBarHairline = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: self.navigationController.navigationBar.tintColor,
                                                           }];
    aryFrames = [NSMutableArray new];
    
    // XXX: tintColor broken, idk 🤷🏼‍♂️
    stpDelay = [[STLStepper alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    stpDelay.minimumValue = 0.5;
    stpDelay.maximumValue = 2.0;
    stpDelay.value = 1.0;
    stpDelay.stepValue = 0.5;
    stpDelay.tintColor = self.navigationController.navigationBar.tintColor;
    self.navigationItem.titleView = stpDelay;
    
    UIView *viewExtendNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame)+8)];
    viewExtendNavBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
    [self.view addSubview:viewExtendNavBar];
    
    drawView = [[STLDesignView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.view.frame)-20, CGRectGetWidth(self.view.frame)-20) withFrame:[self.pattern.frames lastObject]];
    [drawView updateValuesForMatrixSize:self.pattern.hub.matrix];

    __weak typeof(self) weakSelf = self;
    drawView.didFinishDrawing = ^(UIImage *image, STLLightFrame *frame){
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
    
    clvFrames = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(drawView.frame), CGRectGetWidth(self.view.frame)/4*3, 130) collectionViewLayout:flowLayout];
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
    [btnErase addTarget:self action:@selector(erase) forControlEvents:UIControlEventTouchUpInside];
    btnErase.layer.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    btnErase.layer.shadowOpacity = 0.3;
    btnErase.layer.shadowRadius = 8.0;
    btnErase.layer.shadowOffset = CGSizeZero;
    [self.view addSubview:btnErase];
    [clvFrames setFrame:CGRectMake(0, CGRectGetMaxY(drawView.frame)+((CGRectGetMinY(btnErase.frame)-CGRectGetMaxY(drawView.frame))-CGRectGetHeight(clvFrames.frame))/2, CGRectGetWidth(self.view.frame)/4*3, CGRectGetHeight(clvFrames.frame))];
    
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
    
    colorPicker = [[STLColorPicker alloc] initWithFrame:CGRectMake(CGRectGetMinX(drawView.frame), CGRectGetMinY(drawView.frame)+CGRectGetHeight(drawView.frame)/4, CGRectGetWidth(drawView.frame), CGRectGetHeight(drawView.frame)/2)];
    colorPicker.tintColor = [UIColor whiteColor];
    colorPicker.layer.cornerRadius = 7.5;
    colorPicker.layer.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    colorPicker.layer.shadowOpacity = 0.3;
    colorPicker.layer.shadowRadius = 8.0;
    colorPicker.layer.shadowOffset = CGSizeZero;
    colorPicker.alpha = 0.0;
    colorPicker.hidden = YES;
    [self.view addSubview:colorPicker];
    [self.view bringSubviewToFront:drawView];
    
    __weak typeof(STLColorPicker) *weakColorPicker = colorPicker;
    [colorPicker setTappedCenter:^{
        [weakSelf updateColor:weakColorPicker.color];
        [weakSelf handleTapGesture:nil];
    }];
    
    UILabel *lblCenter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(colorPicker.viewCenter.frame), CGRectGetHeight(colorPicker.viewCenter.frame))];
    lblCenter.text = @"Set";
    lblCenter.textAlignment = NSTextAlignmentCenter;
    [colorPicker.viewCenter addSubview:lblCenter];
    
    btnColorPicker = [[STLDownloadCollectionViewCell alloc] initWithFrame:CGRectMake(CGRectGetMaxX(clvFrames.frame)+5, CGRectGetMinY(clvFrames.frame)+10, CGRectGetWidth(self.view.frame)-CGRectGetMaxX(clvFrames.frame)-10-10, CGRectGetHeight(clvFrames.frame)-10-10)];
    [self.view addSubview:btnColorPicker];
    [self updateColor:[UIColor redColor]];
    
    UITapGestureRecognizer *tgrColorPicker = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [btnColorPicker addGestureRecognizer:tgrColorPicker];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)updateColor:(UIColor*)color {
    btnColorPicker.titleLabel.text = [color hexValue];
    btnColorPicker.previewImage.image = [[color image] resize:CGSizeMake(CGRectGetWidth(btnColorPicker.frame), CGRectGetWidth(btnColorPicker.frame))];
    drawView.drawColor = color;
    [colorPicker setValue:color forKey:@"color"];
}
- (void)handleTapGesture:(UITapGestureRecognizer*)recognizer {
    if (colorPicker.hidden == YES) {
        colorPicker.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            colorPicker.alpha = 1.0;
            drawView.alpha = 0.0;
        } completion:^(BOOL finished) {
            drawView.hidden = YES;
        }];
    } else {
        drawView.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            colorPicker.alpha = 0.0;
            drawView.alpha = 1.0;
        } completion:^(BOOL finished) {
            colorPicker.hidden = YES;
        }];
    }
}
- (void)saveAndExit {
    if ([aryFrames count] == 0) {
        [self newFrame];
    }
//    (1000*stpDelay.value)
    
    [self.pattern setFrames:aryFrames];
    
    [_delegate configurationViewController:self withLightPattern:self.pattern];
    [self exit];
}
- (void)exit {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)erase {
    if (drawView.empty) {
        [aryFrames removeAllObjects];
        [clvFrames reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } else {
        [drawView erase];
    }
}
- (void)preview {
    NSMutableArray *aryImages = [NSMutableArray new];
    for (STLLightFrame *frame in self.pattern.frames) {
        UIImage *image = [STLDesignView imageFromFrame:frame];
        [aryImages addObject:image];
    }
    [self presentViewController:[[STLPreviewViewController alloc] initWithImages:aryImages animationDuration:stpDelay.value] animated:YES completion:nil];
}
- (void)advanced {
    UIViewController *viewController = nil;
    viewController = [[STLAdvancedViewController alloc] initWithLightFrame:drawView.lightFrame withSize:drawView.size];
    ((STLAdvancedViewController*)viewController).delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}
- (void)newFrame {
    if (drawView.empty) return;
    if ([aryFrames count] == 20) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Whoops!" message:@"The max number of frames as been met." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (!drawView.image) return;
    STLLightFrame *frame = drawView.lightFrame;
    [aryFrames addObject:frame];
    
    [clvFrames performBatchUpdates:^{
        [clvFrames insertItemsAtIndexPaths:@[
                                             [NSIndexPath indexPathForRow:[aryFrames count]-1 inSection:0],
                                             ]];
    } completion:^(BOOL finished) {
        [clvFrames scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[aryFrames count] inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }];
}
- (void)deleteFrame:(UIButton *)sender {
    if ([aryFrames count] <= 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Whoops!" message:@"An internal error has occured. There are no other cells to delete." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [aryFrames removeObjectAtIndex:sender.tag];
    [clvFrames performBatchUpdates:^{
        [clvFrames deleteItemsAtIndexPaths:@[
                                             [NSIndexPath indexPathForRow:sender.tag inSection:0],
                                             ]];
    } completion:^(BOOL finished) {
        [clvFrames reloadData];
        [clvFrames scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[aryFrames count] inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }];
    // XXX: actually deletes cell but delete button is added to the next cell as well
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
        cell.previewImage.image = [STLDesignView imageFromFrame:[aryFrames objectAtIndex:indexPath.row]];
        cell.previewImage.contentMode = UIViewContentModeScaleAspectFit;
        cell.titleLabel.text = [NSString stringWithFormat:@"%ld",(long)(indexPath.row+1)];
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
        drawView.lightFrame = [aryFrames objectAtIndex:indexPath.row];
    } else {
        [self newFrame];
    }
}

#pragma mark - STLAdvancedViewControllerDelegate
- (void)configurationViewController:(STLAdvancedViewController *)viewController didFinishWithFrame:(STLLightFrame *)frame {
    [drawView erase];
    drawView.lightFrame = frame;
}
@end
