//
//  STLAboutViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/12/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLAboutViewController.h"

#import <ChameleonFramework/Chameleon.h>

@interface STLAboutViewController ()

@end

@implementation STLAboutViewController
static NSString * const reuseIdentifier = @"starlight.about.cell";
- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"About";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIImage *imgBack = nil;
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"_UINavigationBarBackIndicatorView")]) {
            imgBack = ((UIImageView*)view).image;
            imgBack = [UIImage imageWithCGImage:imgBack.CGImage scale:imgBack.scale orientation:UIImageOrientationUpMirrored];
        }
    }
    UIImage *imgColorBack = [imgBack imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(imgBack.size, NO, imgColorBack.scale);
    [self.navigationController.navigationBar.tintColor set];
    [imgColorBack drawInRect:CGRectMake(0, 0, imgBack.size.width, imgColorBack.size.height)];
    imgColorBack = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setTitle:@"Back " forState:UIControlStateNormal];
    [btnBack setImage:imgColorBack forState:UIControlStateNormal];
    btnBack.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    btnBack.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    btnBack.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    [btnBack sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)exit {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Software Updates";
            break;
        case 1:
            return @"Support";
            break;
        case 2:
            return @"Legal";
            break;
        default:
            return @"";
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Check For Update";
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Help";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Report a Problem";
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Terms of Serivce";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Third Part Notices";
        }
    }
    
    return cell;
}
@end
