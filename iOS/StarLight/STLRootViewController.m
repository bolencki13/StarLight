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
#import "STLDataManager.h"
#import "STLSequenceManager.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <ChameleonFramework/Chameleon.h>

@interface STLRootViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, STLConfigurationViewControllerDelegate> {
    NSArray<STLHub*>*aryHubs;
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
    UIButton *btnInfo = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [btnInfo setTintColor:self.navigationController.navigationBar.tintColor];
    [btnInfo addTarget:self action:@selector(about) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnInfo];
    
    UIView *viewExtendNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame)+8)];
    viewExtendNavBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
    [self.view insertSubview:viewExtendNavBar belowSubview:self.collectionView];
    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.bounces = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[STLRootCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    
    UIRefreshControl *rfcCollectionView = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    [rfcCollectionView addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:rfcCollectionView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.title = @"StarLight";
    [self handleRefresh:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.title = @"Back";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)handleRefresh:(id)sender {
    [[STLDataManager sharedManager] reloadData:^(NSArray *hubs) {
        aryHubs = [NSArray arrayWithArray:hubs];
        [self.collectionView reloadData];
        if ([sender isKindOfClass:[UIRefreshControl class]]) [sender endRefreshing];
    }];
}

#pragma mark - Actions
- (void)addLights {
    [self.navigationController pushViewController:[NSClassFromString(@"STLDeviceDiscoveryViewController") new] animated:YES];
}
- (void)about {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromLeft;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:[NSClassFromString(@"STLAboutViewController") new] animated:NO];
}
- (void)buy {
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ([aryHubs count] > 0 ? [aryHubs count] : 0);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STLRootCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.text = [aryHubs objectAtIndex:indexPath.row].name;
    cell.locationLabel.text = [aryHubs objectAtIndex:indexPath.row].location;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    STLHub *hub = [aryHubs objectAtIndex:indexPath.row];
    
    STLConfigurationViewController *configurationViewController = [[STLConfigurationViewController alloc] initWithHub:hub withCurrentImage:((STLRootCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath]).designView.image];
    configurationViewController.delegate = self;
    [self.navigationController pushViewController:configurationViewController animated:YES];
}

#pragma mark - DZNEmptyDataSetSource
- (UIView*)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.collectionView.center.x-200, CGRectGetWidth(self.view.frame), 200)];
    contentView.backgroundColor = [UIColor redColor];
    
    NSString *text = @"No StarLights found.";
    NSMutableAttributedString *astrText = [[NSMutableAttributedString alloc] initWithString:text];
    [astrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize]+16] range:[text rangeOfString:text]];
    [astrText addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:[text rangeOfString:text]];

    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(contentView.frame), 60)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.attributedText = astrText;
    [contentView addSubview:lblTitle];
    
    UIButton *btnBuy = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBuy setFrame:CGRectMake(20, CGRectGetMaxY(lblTitle.frame), (CGRectGetWidth(contentView.frame)-60)/2, 60)];
    [btnBuy addTarget:self action:@selector(buy) forControlEvents:UIControlEventTouchUpInside];
    [btnBuy setTitle:@"Buy StartLight" forState:UIControlStateNormal];
    [btnBuy setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnBuy setBackgroundColor:[UIColor clearColor]];
    [btnBuy.layer setCornerRadius:7.5];
    [btnBuy.layer setMasksToBounds:YES];
    [btnBuy.layer setBorderColor:[btnBuy titleColorForState:UIControlStateNormal].CGColor];
    [btnBuy.layer setBorderWidth:2];
    [btnBuy setShowsTouchWhenHighlighted:YES];
    [contentView addSubview:btnBuy];

    UIButton *btnPair = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPair setFrame:CGRectMake(CGRectGetMaxX(btnBuy.frame)+20, CGRectGetMinY(btnBuy.frame), (CGRectGetWidth(contentView.frame)-60)/2, CGRectGetHeight(btnBuy.frame))];
    [btnPair addTarget:self action:@selector(addLights) forControlEvents:UIControlEventTouchUpInside];
    [btnPair setTitle:@"Add New" forState:UIControlStateNormal];
    [btnPair setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnPair setBackgroundColor:[UIColor clearColor]];
    [btnPair.layer setCornerRadius:7.5];
    [btnPair.layer setMasksToBounds:YES];
    [btnPair.layer setBorderColor:[btnPair titleColorForState:UIControlStateNormal].CGColor];
    [btnPair.layer setBorderWidth:2];
    [contentView addSubview:btnPair];

    /*
     
     XXX: Touches are not passed due to bug in library; Category to override?
     
     */
    
    return contentView;
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - STLConfigurationViewControllerDelegate
- (void)configurationViewController:(STLConfigurationViewController *)viewController didFinishWithImage:(UIImage *)image {
    ((STLRootCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[aryHubs indexOfObject:viewController.hub] inSection:0]]).designView.image = image;
}
@end
