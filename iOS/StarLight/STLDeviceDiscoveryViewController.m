//
//  STLDeviceDiscoveryViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/22/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLDeviceDiscoveryViewController.h"
#import "STLBluetoothManager.h"
#import "STLCalibrationViewController.h"

#import <Chameleon.h>

@interface STLDeviceDiscoveryViewController () {
    NSArray<CBPeripheral*> *aryDevices;
}
@end

@implementation STLDeviceDiscoveryViewController
static NSString * const reuseIdentifier = @"starlight.device.cell";
- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0 , 0, CGRectGetWidth(self.tableView.frame), 150)];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15 , 10, CGRectGetWidth(viewHeader.frame)-30, CGRectGetHeight(viewHeader.frame)-20)];
    lblTitle.text = @"Start by choosing a\nStarLight to connect to.";
    lblTitle.textColor = self.navigationController.navigationBar.barTintColor;
    lblTitle.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]+20];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.numberOfLines = 2;
    lblTitle.adjustsFontSizeToFitWidth = YES;
    [viewHeader addSubview:lblTitle];
    self.tableView.tableHeaderView = viewHeader;
    
    [self handleRefresh:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)handleRefresh:(id)sender {
    [[STLBluetoothManager sharedManager] startScanningForDevices:^(NSArray<CBPeripheral *> *peripherals) {
        aryDevices = peripherals;
        [self.tableView reloadData];
        if ([sender isKindOfClass:[UIRefreshControl class]]) [sender endRefreshing];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [aryDevices count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.text = [aryDevices objectAtIndex:indexPath.row].name;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[STLBluetoothManager sharedManager] connectToPeripheral:[aryDevices objectAtIndex:indexPath.row] success:^(CBPeripheral *peripheral) {
        [self.navigationController pushViewController:[[STLCalibrationViewController alloc] initWithPeripheral:peripheral] animated:YES];
    } failed:^(NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Whoops!" message:[NSString stringWithFormat:@"An error occured durring connection. %@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}
@end
