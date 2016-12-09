//
//  ViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/6/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLRootViewController.h"
#import "STLRootTableViewCell.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface STLRootViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate> {
    NSArray *aryLightPods;
}
@end

@implementation STLRootViewController
- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.navigationController.navigationBar.tintColor;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLights)];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    
    aryLightPods = @[
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

#pragma mark - Actions
- (void)addLights {
    [self.navigationController pushViewController:[NSClassFromString(@"STLCalibrationViewController") new] animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [aryLightPods count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"com.bolencki13.starlight.root-cell";
    STLRootTableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[STLRootTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"Whoops!\nNo StarLights where found";
    
    NSMutableAttributedString *astrText = [[NSMutableAttributedString alloc] initWithString:text];

    [astrText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]+26] range:[text rangeOfString:@"Whoops!"]];
    [astrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize]+8] range:[text rangeOfString:@"No StarLights where found"]];
    
    return astrText;
}

#pragma mark - DZNEmptyDataSetDelegate
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self addLights];
}
@end
