//
//  STLAdvancedViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLAdvancedViewController.h"
#import "STLDownloadCollectionViewCell.h"
#import "STLMultiDirectionLayout.h"
#import "NS2DArray.h"
#import "STLLightFrame.h"
#import "STLLight.h"
#import "STLHub.h"

#import <ChameleonFramework/Chameleon.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface STLAdvancedViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate> {
    UIView *contentView;
    UINavigationItem *navItem;
}
@end

@implementation STLAdvancedViewController
static NSString * const reuseIdentifier = @"starlight.advanced.cell";
- (instancetype)initWithLightFrame:(STLLightFrame*)frame withSize:(NSIndexPath*)size {
    self = [super init];
    if (self) {
        _lightFrame = frame;
        _lightState = [NS2DArray arrayWithSections:size.section rows:size.row];
        _lightColor = [NS2DArray arrayWithSections:size.section rows:size.row];
        
        for (NSInteger section = 0; section < size.section; section++) {
            for (NSInteger row = 0; row < size.row; row++) {
                [_lightState setObject:[NSNumber numberWithInteger:0] atIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
        [_lightFrame enumerateFrame:^(NSString *hexColor, NSInteger position) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(position % _lightState.sections) inSection:(int)(position/_lightState.sections)];
            NSLog(@"%@",indexPath);
            [_lightState setObject:[NSNumber numberWithInteger:1] atIndexPath:indexPath];
            [_lightColor setObject:[UIColor colorWithHexString:hexColor] atIndexPath:indexPath];
        }];
        
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    contentView.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    contentView.layer.cornerRadius = 7.5;
    contentView.layer.masksToBounds = YES;
    [self.view addSubview:contentView];
    
    navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Advanced";

    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(exit)];
    navItem.leftBarButtonItem = btnDone;

    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    navBar.tintColor = [UINavigationBar appearance].barTintColor;
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UINavigationBar appearance].barTintColor, NSFontAttributeName : [UIFont boldSystemFontOfSize:[UIFont systemFontSize]+6]}];
    navBar.barTintColor = contentView.backgroundColor;
    navBar.layer.cornerRadius = contentView.layer.cornerRadius;
    navBar.shadowImage = [UIImage new];
    [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    navBar.items = @[navItem];
    [contentView addSubview:navBar];
    
    STLMultiDirectionLayout *multiDirectionLayout = [STLMultiDirectionLayout new];
    [multiDirectionLayout setItemSize:CGSizeMake(80, 110)];
    
    UICollectionView *clvMatrix = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMinY(contentView.frame)-CGRectGetMaxY(navBar.frame)) collectionViewLayout:multiDirectionLayout];
    clvMatrix.dataSource = self;
    clvMatrix.delegate = self;
    clvMatrix.showsHorizontalScrollIndicator = NO;
    clvMatrix.showsVerticalScrollIndicator = NO;
    clvMatrix.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    [clvMatrix registerClass:[STLDownloadCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    clvMatrix.emptyDataSetSource = self;
    clvMatrix.emptyDataSetDelegate = self;
    [contentView addSubview:clvMatrix];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)saveAndExit {
    __weak typeof(NS2DArray*) weakState = _lightState;
    [_lightFrame setStateForLight:^BOOL(STLLight *light) {
        NSInteger state = [[weakState objectAtIndexPath:[NSIndexPath indexPathForRow:(light.position % _lightState.sections) inSection:(light.position % _lightState.sections)]] integerValue];
        return ((state <=0) ? NO : YES);
    }];
    
    __weak typeof(NS2DArray*) weakColors = _lightColor;
    [_lightFrame setColorForLight:^UIColor *(STLLight *light) {
        return [weakColors objectAtIndexPath:[NSIndexPath indexPathForRow:(light.position % weakState.sections) inSection:(light.position % weakState.sections)]];
    }];
    [_lightFrame reloadFrame];
    
    [_delegate configurationViewController:self didFinishWithFrame:_lightFrame];
    [self exit];
}
- (void)exit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    [collectionView.collectionViewLayout invalidateLayout];
    return [_lightState sections];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_lightState rows];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STLDownloadCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"(%ld,%ld)",(long)indexPath.section+1, (long)indexPath.row+1];
    if ([[_lightState objectAtIndexPath:indexPath] integerValue] != -1) {
        cell.previewImage.backgroundColor = ([[_lightState objectAtIndexPath:indexPath] boolValue] == YES) ?[_lightColor objectAtIndexPath:indexPath] : [UIColor lightGrayColor];
        cell.userInteractionEnabled = YES;
    } else {
        cell.previewImage.backgroundColor = [UIColor lightGrayColor];
        cell.userInteractionEnabled = NO;
    }
    cell.layer.cornerRadius = 0.0;
    cell.contentView.layer.cornerRadius = 0.0;
    cell.previewImage.layer.cornerRadius = 0.0;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [_lightState setObject:[NSNumber numberWithBool:![[_lightState objectAtIndexPath:indexPath] boolValue]] atIndexPath:indexPath];
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exit)];
    navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveAndExit)];
}
@end
