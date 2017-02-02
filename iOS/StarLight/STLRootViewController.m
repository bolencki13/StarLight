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
#import "STLCalibrationViewController.h"
#import "STLStoreViewController.h"
#import "STLDataManager.h"
#import "STLSequenceManager.h"
#import "NS2DArray.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <ChameleonFramework/Chameleon.h>

@interface STLRootViewController () <UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, STLConfigurationViewControllerDelegate, STLCalibrationViewControllerDelegate> {
    NSMutableArray<STLHub*> *aryHubs;
}
@property (nonatomic, retain, readonly) UITableView *tableView;
@end

@implementation STLRootViewController
static NSString * const reuseIdentifier = @"starlight.root.cell";
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
    [self.view addSubview:viewExtendNavBar];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-20) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://starlighthub.com/index.html#purchase"]];
}
- (UIViewController*)actionForIndexPath:(NSIndexPath*)indexPath {
    STLHub *hub = [aryHubs objectAtIndex:indexPath.row];
    NSArray<NS2DArray*> *states = ((STLRootTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).states;
    
    STLConfigurationViewController *configurationViewController = [[STLConfigurationViewController alloc] initWithHub:hub withStates:states];
    configurationViewController.delegate = self;
    return configurationViewController;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([aryHubs count] > 0 ? [aryHubs count] : 0);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [STLRootTableViewCell defaultCellHeight];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STLRootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[STLRootTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    __weak typeof(STLRootTableViewCell*) weakCell = cell;
    
    STLHub *hub = [aryHubs objectAtIndex:indexPath.row];
    [cell setTitle:hub.name];
    [cell setLocation:hub.location];
    [cell setCellShouldBeRemoved:^{
        NSError *error = nil;
        if ([[STLDataManager sharedManager] removeHub:hub error:&error]) {
            [aryHubs removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadEmptyDataSet];
        } else {
            NSLog(@"Error while deleting hub: %@",error);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Whoops!" message:@"An error occured while trying to delete the StarLight. Try again." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    [cell setCellDetailActivate:^{
        [self.navigationController pushViewController:[self actionForIndexPath:indexPath] animated:YES];
    }];
    [cell setCellShouldBeFlash:^{
        STLLightPattern *pattern = [STLLightPattern pattern];
        pattern.delay = (uint32_t)weakCell.delay;
        pattern.states = weakCell.states;
        pattern.lights = hub.lightMatrix;
        pattern.colorForLightIndexWithFrame = ^ UIColor *(NSInteger lightIndex, NSInteger frame) {
            return [UIColor redColor];
        };
        [pattern reloadPattern];
        [[STLSequenceManager sharedManager] uploadPattern:pattern];
    }];
    [cell setCellLongHoldActivate:^{
        [weakCell animate];
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController pushViewController:[STLStoreViewController new] animated:YES];
}

#pragma mark - UIViewControllerPreviewingDelegate
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    return [self actionForIndexPath:[self.tableView indexPathForRowAtPoint:location]];
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"No StarLights found";
    NSMutableAttributedString *astrText = [[NSMutableAttributedString alloc] initWithString:text];
    [astrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize]+16] range:[text rangeOfString:text]];
    [astrText addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:[text rangeOfString:text]];

    return astrText;
}
- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    Class DZNEmptyDataSetView = objc_getClass("DZNEmptyDataSetView");
    
    if (DZNEmptyDataSetView) {
        for (UIView *view in scrollView.subviews) {
            if ([view isKindOfClass:DZNEmptyDataSetView]) {
                Ivar ivar_button = class_getInstanceVariable([((id)view) class], "_button");
                UIButton *button = object_getIvar(view, ivar_button);
                button.layer.borderWidth = 2.5;
                button.layer.borderColor = [UIColor lightGrayColor].CGColor;
                button.layer.cornerRadius = 7.5;
                button.layer.masksToBounds = YES;
            }
        }
    }
    
    NSString *text = @"Buy StarLight";
    NSMutableAttributedString *astrText = [[NSMutableAttributedString alloc] initWithString:text];
    [astrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize]+10] range:[text rangeOfString:text]];
    [astrText addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:[text rangeOfString:text]];
    return astrText;
}

#pragma mark - DZNEmptyDataSetDelegate
- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self buy];
}

#pragma mark - STLConfigurationViewControllerDelegate
- (void)configurationViewController:(STLConfigurationViewController *)viewController states:(NSArray<NS2DArray *> *)states withDelay:(NSInteger)delay {
    [((STLRootTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[aryHubs indexOfObject:viewController.hub] inSection:0]]) setStates:states];
    [((STLRootTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[aryHubs indexOfObject:viewController.hub] inSection:0]]) setDelay:delay];
}

#pragma mark - STLCalibrationViewControllerDelegate
- (void)calibrationdidFinish:(STLCalibrationViewController *)viewController withHub:(STLHub *)hub {
    NSError *error = nil;
    [[STLDataManager sharedManager] saveData:&error];
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"StarLight" message:@"An error occured when trying to add the StarLight" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:self animated:YES completion:nil];
        NSLog(@"%@",error);
    } else {
        [self handleRefresh:nil];
    }
}
@end
