//
//  ViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/6/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLRootViewController.h"
#import "STLRootTableViewCell.h"
#import "STLConfigurationViewController.h"
#import "STLDataManager.h"
#import "STLSequenceManager.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <ChameleonFramework/Chameleon.h>

@interface STLRootViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, STLConfigurationViewControllerDelegate> {
    NSMutableArray<STLHub*> *aryHubs;
}
@end

@implementation STLRootViewController
static NSString * const reuseIdentifier = @"starlight.root.cell";
- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
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
    
//    UIView *viewExtendNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame)+8)];
//    viewExtendNavBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
//    [self.view insertSubview:viewExtendNavBar belowSubview:self.tableView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    UIRefreshControl *rfcCollectionView = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    [rfcCollectionView addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:rfcCollectionView];
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
        aryHubs = [[NSArray arrayWithArray:hubs] mutableCopy];
        [self.tableView reloadData];
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([aryHubs count] > 0 ? [aryHubs count] : 0);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108; // 8 due to the 'GAP_ACTION' found in 'STLRootTableViewCell'
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STLRootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[STLRootTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    [cell setDrawImage:[UIImage new]];
    [cell setTitle:[aryHubs objectAtIndex:indexPath.row].name];
    [cell setLocation:[aryHubs objectAtIndex:indexPath.row].location];
    [cell setCellShouldBeRemoved:^{
        NSError *error = nil;
        if ([[STLDataManager sharedManager] removeHub:[aryHubs objectAtIndex:indexPath.row] error:&error]) {
            [aryHubs removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (error) {
            NSLog(@"Error while deleting hub: %@",error);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Whoops!" message:@"An error occured while trying to delete the StarLight. Try again." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    [cell setCellDetailActivate:^{
        NSLog(@"Details activate");
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    STLHub *hub = [aryHubs objectAtIndex:indexPath.row];
    
    STLConfigurationViewController *configurationViewController = [[STLConfigurationViewController alloc] initWithHub:hub withCurrentImage:((STLRootTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).drawImage];
    configurationViewController.delegate = self;
    [self.navigationController pushViewController:configurationViewController animated:YES];
}

#pragma mark - DZNEmptyDataSetSource
- (UIView*)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.center.x-200, CGRectGetWidth(self.view.frame), 200)];
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
    // image is not being set
    ((STLRootTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[aryHubs indexOfObject:viewController.hub] inSection:0]]).drawImage = image;
}
@end
