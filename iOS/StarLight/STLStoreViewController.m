//
//  STLStoreViewController.m
//  StarLight
//
//  Created by Brian Olencki on 1/23/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import "STLStoreViewController.h"
#import "STLRootTableViewCell.h"
#import "STLHub.h"

#import <Chameleon.h>

@interface STLStoreViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *aryPatterns;
}
@property (nonatomic, retain, readonly) UIScrollView *scvTopMenu;
@property (nonatomic, retain, readonly) UIPageControl *pgcTopMenu;
@property (nonatomic, retain, readonly) UITableView *tblPatterns;
@end

@implementation STLStoreViewController
static NSString *reuseIdentifier = @"com.bolencki13.starlight.cell.store";
- (instancetype)initWithHub:(STLHub *)hub {
    self = [super init];
    if (self) {
        _hub = hub;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Nebula";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    
    aryPatterns = [NSMutableArray new];
    
    _scvTopMenu = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)/4)];
    _scvTopMenu.backgroundColor = [UIColor redColor];
    [self.view addSubview:_scvTopMenu];
    
    _pgcTopMenu = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scvTopMenu.frame), CGRectGetWidth(self.scvTopMenu.frame), 20)];
    _pgcTopMenu.numberOfPages = 4;
    [self.view addSubview:_pgcTopMenu];
    
    _tblPatterns = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.pgcTopMenu.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.pgcTopMenu.frame)-CGRectGetHeight(self.navigationController.navigationBar.frame)-CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)) style:UITableViewStylePlain];
    _tblPatterns.backgroundColor = [UIColor clearColor];
    _tblPatterns.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tblPatterns.dataSource = self;
    _tblPatterns.delegate = self;
    [self.view addSubview:_tblPatterns];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;//[aryPatterns count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [STLRootTableViewCell defaultCellHeight];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STLRootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[STLRootTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

@end
