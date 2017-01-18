//
//  STLAboutViewController.m
//  StarLight
//
//  Created by Brian Olencki on 12/12/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLAboutViewController.h"

#import <ChameleonFramework/Chameleon.h>
#import <SafariServices/SafariServices.h>

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

#pragma mark - Updating
- (BOOL)checkForUpdate {
    return NO;
}
- (void)update {
    
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            BOOL updateAvailable = [self checkForUpdate];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"StarLight" message:(updateAvailable ? @"Update Available, Would you like to update?" : @"Softare is Up-To-Date") preferredStyle:UIAlertControllerStyleAlert];
            if (updateAvailable) {
                [alert addAction:[UIAlertAction actionWithTitle:@"Not now" style:UIAlertActionStyleCancel handler:nil]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self update];
                }]];
            } else {
                [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
            }
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://starlighthub.com/help"]];
        } else if (indexPath.row == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://starlighthub.com/report"]];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://starlighthub.com/terms"]];
        } else if (indexPath.row == 1) {
            [self.navigationController pushViewController:[NSClassFromString(@"STLThirdPartyNoticesViewController") new] animated:YES];
        }
    }
}
@end
