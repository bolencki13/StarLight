//
//  STLPreviewViewController.m
//  StarLight
//
//  Created by Brian Olencki on 1/17/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import "STLPreviewViewController.h"

#import <Chameleon.h>

@interface STLPreviewViewController () {
    UIView *contentView;
    UINavigationItem *navItem;

    UIImageView *imgViewAnimation;
}
@end

@implementation STLPreviewViewController
- (instancetype)initWithImages:(NSArray<UIImage *> *)images animationDuration:(CGFloat)duration {
    self = [super init];
    if (self) {
        _images = images;
        _duration = duration;
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    contentView.backgroundColor = [UIColor colorWithHexString:@"#EEF9FF"];
    contentView.layer.cornerRadius = 7.5;
    contentView.layer.masksToBounds = YES;
    [self.view addSubview:contentView];
    
    navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Preview";
    
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
    
    imgViewAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame)-8-8, CGRectGetWidth(self.view.frame)-8-8)];
    imgViewAnimation.animationImages = _images;
    imgViewAnimation.animationDuration = _duration*[_images count];
    imgViewAnimation.animationRepeatCount = 0;
    imgViewAnimation.center = self.view.center;
    [self.view addSubview:imgViewAnimation];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [imgViewAnimation startAnimating];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [imgViewAnimation stopAnimating];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)exit {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
