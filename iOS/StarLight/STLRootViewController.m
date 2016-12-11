//
//  ViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/6/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLRootViewController.h"
#import "STLRootCollectionViewCell.h"
#import "STLConfigurationViewController.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <ChameleonFramework/Chameleon.h>

@interface STLRootViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, STLConfigurationViewControllerDelegate> {
    NSArray *aryLightPods;
}
@end

@implementation STLRootViewController
static NSString * const reuseIdentifier = @"starlight.root.cell";
- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setSectionInset:UIEdgeInsetsMake(15,15,15,15)];
    [flowLayout setItemSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-30, 100)];
    [flowLayout setMinimumInteritemSpacing:15];
    [flowLayout setMinimumLineSpacing:15];
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {

    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* BLUE: #EEF9FF GREEN: #EEFFF9 */
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    
    self.navigationController.hidesNavigationBarHairline = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLights)];
    
    UIView *viewExtendNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame)+8)];
    viewExtendNavBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
    [self.view insertSubview:viewExtendNavBar belowSubview:self.collectionView];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.bounces = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[STLRootCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    self.collectionView.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    [self.collectionView.refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    
    aryLightPods = @[
                     @"1",
                     @"2",
                     ];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"StarLight";
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.title = @"Back";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)handleRefresh {
    
    /* Refresh lighs in the table. make sure each is reachable */
    
    [self.collectionView.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
}

#pragma mark - Actions
- (void)addLights {
    [self.navigationController pushViewController:[NSClassFromString(@"STLCalibrationViewController") new] animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [aryLightPods count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STLRootCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"StarLight Hub %ld",indexPath.row+1];
    cell.locationLabel.text = (indexPath.row == 0 ? @"Backyard" : @"Tree by Gallows");
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id hub = [aryLightPods objectAtIndex:indexPath.row];
    
    STLConfigurationViewController *configurationViewController = [[STLConfigurationViewController alloc] initWithHub:hub withCurrentImage:((STLRootCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath]).designView.image];
    configurationViewController.delegate = self;
    [self.navigationController pushViewController:configurationViewController animated:YES];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"Whoops!\nNo StarLights where found";
    
    NSMutableAttributedString *astrText = [[NSMutableAttributedString alloc] initWithString:text];

    [astrText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]+26] range:[text rangeOfString:@"Whoops!"]];
    [astrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize]+8] range:[text rangeOfString:@"No StarLights where found"]];
    [astrText addAttribute:NSForegroundColorAttributeName value:self.navigationController.navigationBar.barTintColor range:[text rangeOfString:text]];
    
    return astrText;
}

#pragma mark - DZNEmptyDataSetDelegate
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self addLights];
}

#pragma mark - STLConfigurationViewControllerDelegate
- (void)configurationViewController:(STLConfigurationViewController *)viewController didFinishWithImage:(UIImage *)image {
    ((STLRootCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[aryLightPods indexOfObject:viewController.hub] inSection:0]]).designView.image = image;
}
@end
