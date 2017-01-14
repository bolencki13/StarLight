//
//  STLRootCollectionViewCell.m
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLRootTableViewCell.h"

#import <ChameleonFramework/Chameleon.h>

#define MAX_ACTION_WIDTH (100)
#define GAP_ACTION (8)
#define DEFAULT_ROOT_FRAME (CGRectMake(GAP_ACTION, GAP_ACTION, CGRectGetWidth(self.frame)-GAP_ACTION*2, CGRectGetHeight(self.frame)-GAP_ACTION*2))

@interface STLRootTableViewCell () <UIGestureRecognizerDelegate> {
    UIPanGestureRecognizer *pgrSwipeAction;

    UIView *viewRootContent;
    UIImageView *imgViewDrawing;
    UILabel *lblTitle;
    UILabel *lblLocation;
    UIButton *btnDetails;
    
    UIView *viewActionContent;
    UIButton *btnDelete;
    
    BOOL _actionMenuOpen;
    BOOL _panning;
    CGFloat _startingX;
    CGFloat _panningX;
    CGFloat _lastChange;
}
@end

@implementation STLRootTableViewCell
+ (CGFloat)defaultCellHeight {
    return 100+GAP_ACTION;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self sharedInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}
- (void)sharedInit {
    _actionMenuOpen = NO;
    _panning = NO;
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    viewRootContent = [[UIView alloc] initWithFrame:DEFAULT_ROOT_FRAME];
    viewRootContent.backgroundColor = [UIColor whiteColor];
    viewRootContent.layer.cornerRadius = 7.5;
    viewRootContent.layer.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    viewRootContent.layer.shadowOpacity = 0.3;
    viewRootContent.layer.shadowRadius = 8.0;
    viewRootContent.layer.shadowOffset = CGSizeZero;
    [self.contentView addSubview:viewRootContent];
    
    imgViewDrawing = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetHeight(viewRootContent.frame)-20, CGRectGetHeight(viewRootContent.frame)-20)];
    imgViewDrawing.layer.cornerRadius = viewRootContent.layer.cornerRadius;
    imgViewDrawing.backgroundColor = [UIColor colorWithHexString:@"EEF9FF"];
    imgViewDrawing.layer.borderColor = [UINavigationBar appearance].barTintColor.CGColor;
    imgViewDrawing.layer.borderWidth = 1.0;
    imgViewDrawing.layer.masksToBounds = YES;
    imgViewDrawing.userInteractionEnabled = YES;
    [viewRootContent addSubview:imgViewDrawing];
    
    UITapGestureRecognizer *tgrImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDetails)];
    [imgViewDrawing addGestureRecognizer:tgrImage];
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgViewDrawing.frame)+10, CGRectGetMinY(imgViewDrawing.frame), CGRectGetWidth(viewRootContent.frame)-10-CGRectGetMaxX(imgViewDrawing.frame)-10, CGRectGetHeight(imgViewDrawing.frame)/2)];
    lblTitle.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]+6];
    lblTitle.textColor = [UIColor colorWithCGColor:imgViewDrawing.layer.borderColor];
    [viewRootContent addSubview:lblTitle];

    lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgViewDrawing.frame)+10, CGRectGetMaxY(lblTitle.frame)-10, CGRectGetWidth(lblTitle.frame), CGRectGetHeight(lblTitle.frame))];
    lblLocation.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    lblLocation.textColor = [lblTitle.textColor colorWithAlphaComponent:0.8];
    [viewRootContent addSubview:lblLocation];
    
    btnDetails = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [btnDetails addTarget:self action:@selector(handleDetails) forControlEvents:UIControlEventTouchUpInside];
    [btnDetails setFrame:CGRectMake(CGRectGetWidth(viewRootContent.frame)-50, (CGRectGetHeight(viewRootContent.frame)-40)/2, 40, 40)];
    [btnDetails setBackgroundColor:[UIColor whiteColor]];
    [btnDetails setTintColor:lblTitle.textColor];
    [viewRootContent addSubview:btnDetails];
    
    pgrSwipeAction = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pgrSwipeAction.delegate = self;
    [viewRootContent addGestureRecognizer:pgrSwipeAction];
    
    viewActionContent = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(viewRootContent.frame)+GAP_ACTION, CGRectGetMinY(viewRootContent.frame), CGRectGetWidth(self.frame)-CGRectGetMaxX(viewRootContent.frame)-GAP_ACTION-GAP_ACTION, CGRectGetHeight(viewRootContent.frame))];
    viewActionContent.layer.cornerRadius = viewRootContent.layer.cornerRadius;
    viewActionContent.backgroundColor = viewRootContent.backgroundColor;
    viewActionContent.layer.shadowColor = viewRootContent.layer.shadowColor;
    viewActionContent.layer.shadowOpacity = viewRootContent.layer.shadowOpacity;
    viewActionContent.layer.shadowOffset = viewRootContent.layer.shadowOffset;
    viewActionContent.alpha = 0.0;
    [self.contentView insertSubview:viewActionContent belowSubview:viewRootContent];
    
    btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDelete addTarget:self action:@selector(handleAction) forControlEvents:UIControlEventTouchUpInside];
    [btnDelete setFrame:viewActionContent.bounds];
    [btnDelete setTitle:@"Delete" forState:UIControlStateNormal];
    [btnDelete.titleLabel setFont:lblTitle.font];
    btnDelete.layer.cornerRadius = viewActionContent.layer.cornerRadius;
    [btnDelete setBackgroundColor:[UIColor colorWithHexString:@"#FF3B31"]];
    [viewActionContent addSubview:btnDelete];
    
    [self bringSubviewToFront:viewRootContent];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateFrames];
}

#pragma mark - Private
- (void)updateFrames {
    if (!_panning) {
        if (_actionMenuOpen) {
            viewRootContent.frame = CGRectMake(CGRectGetMinY(DEFAULT_ROOT_FRAME)-MAX_ACTION_WIDTH-GAP_ACTION, CGRectGetMinY(DEFAULT_ROOT_FRAME), CGRectGetWidth(DEFAULT_ROOT_FRAME), CGRectGetHeight(DEFAULT_ROOT_FRAME));
        } else {
            viewRootContent.frame = DEFAULT_ROOT_FRAME;
        }
    }
    imgViewDrawing.frame = CGRectMake(10, 10, CGRectGetHeight(viewRootContent.frame)-20, CGRectGetHeight(viewRootContent.frame)-20);
    lblTitle.frame = CGRectMake(CGRectGetMaxX(imgViewDrawing.frame)+10, CGRectGetMinY(imgViewDrawing.frame)+7, CGRectGetWidth(viewRootContent.frame)-10-CGRectGetMaxX(imgViewDrawing.frame)-10, CGRectGetHeight(imgViewDrawing.frame)/2);
    lblLocation.frame = CGRectMake(CGRectGetMaxX(imgViewDrawing.frame)+10, CGRectGetMaxY(lblTitle.frame)-10, CGRectGetWidth(lblTitle.frame), CGRectGetHeight(lblTitle.frame));
    btnDetails.frame = CGRectMake(CGRectGetWidth(viewRootContent.frame)-50, (CGRectGetHeight(viewRootContent.frame)-40)/2, 40, 40);
    viewActionContent.frame = CGRectMake(CGRectGetMaxX(viewRootContent.frame)+GAP_ACTION, CGRectGetMinY(viewRootContent.frame), CGRectGetWidth(self.frame)-CGRectGetMaxX(viewRootContent.frame)-GAP_ACTION-GAP_ACTION, CGRectGetHeight(viewRootContent.frame));
    btnDelete.frame = viewActionContent.bounds;
    
    if (_actionMenuOpen) {
        viewActionContent.alpha = 1.0;
    } else {
        viewActionContent.alpha = [self alphaForPercentRevealed:(CGFloat)((CGFloat)(ABS(CGRectGetMinX(viewRootContent.frame))-GAP_ACTION)/CGRectGetMinX(viewActionContent.frame))*4];
    }
}
- (void)handlePan:(UIPanGestureRecognizer*)recognizer {
    CGPoint translation = [recognizer translationInView:viewRootContent];
    CGPoint location = [recognizer locationInView:viewRootContent];
    CGPoint velocity = [recognizer velocityInView:viewRootContent];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _panning = YES;
        _startingX = location.x;
        _panningX = translation.x;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        _lastChange = CFAbsoluteTimeGetCurrent();
        if (location.x > _startingX) {
            _startingX = location.x;
        }
        
        CGFloat translated = translation.x - _panningX;
        if (CGRectGetMinX(viewRootContent.frame) + translated <= GAP_ACTION) {
            if (CGRectGetMinX(viewRootContent.frame) + translated <= (CGRectGetWidth(viewRootContent.frame)*0.95)*-1) {
                viewRootContent.frame = CGRectMake((CGRectGetWidth(viewRootContent.frame)*0.95)*-1, CGRectGetMinY(viewRootContent.frame), CGRectGetWidth(viewRootContent.frame), CGRectGetHeight(viewRootContent.frame));
            } else {
                viewRootContent.frame = CGRectMake(CGRectGetMinX(viewRootContent.frame)+translated, CGRectGetMinY(viewRootContent.frame), CGRectGetWidth(viewRootContent.frame), CGRectGetHeight(viewRootContent.frame));
            }
        } else if (CGRectGetMinX(viewRootContent.frame) + translated > GAP_ACTION) {
            viewRootContent.frame = DEFAULT_ROOT_FRAME;
        }
        [self updateFrames];
        _panningX = translation.x;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        _panning = NO;

        CGFloat curTime = CFAbsoluteTimeGetCurrent();
        CGFloat timeElapsed = curTime - _lastChange;
        CGPoint finalSpeed;
        if (timeElapsed < 0.5) {
            finalSpeed = velocity;
        } else {
            finalSpeed = CGPointZero;
        }
        
        if (CGRectGetMinX(viewRootContent.frame)*-1 > MAX_ACTION_WIDTH || (finalSpeed.x < (CGFloat)-500 && CGRectGetMinX(viewRootContent.frame) < 8)) {
            _actionMenuOpen = YES;

        } else {
            _actionMenuOpen = NO;
        }
        [UIView animateWithDuration:0.25f animations:^{
            [self updateFrames];
        }];
        return;
    }
    viewActionContent.alpha = [self alphaForPercentRevealed:(CGFloat)((CGFloat)(ABS(CGRectGetMinX(viewRootContent.frame))-GAP_ACTION)/CGRectGetMinX(viewActionContent.frame))*4];
}
- (CGFloat)alphaForPercentRevealed:(CGFloat)percent {
    CGFloat arg1 = fmin((CGFloat)1.0,percent);
    CGFloat arg3 = (CGFloat)CGRectGetMinX(viewActionContent.frame);
    CGFloat arg2 = (CGFloat)0.0;
    if ((arg1 * arg3) > 30.0) {
        arg2 = ((arg1 * arg3) + -30.0) / (arg3 + -30.0);
    }
    return arg2;
}
- (void)handleAction {
    if (self.cellShouldBeRemoved) self.cellShouldBeRemoved();
}
- (void)handleDetails {
    if (self.cellDetailActivate) self.cellDetailActivate();
}

#pragma mark - Public
- (UIImage*)drawImage {
    return imgViewDrawing.image;
}
- (void)setDrawImage:(UIImage *)image {
    imgViewDrawing.image = image;
}
- (void)setTitle:(NSString *)title {
    lblTitle.text = title;
    [lblTitle sizeToFit];
}
- (void)setLocation:(NSString *)location {
    lblLocation.text = location;
    [lblLocation sizeToFit];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:pgrSwipeAction]) {
        CGPoint translation = [((UIPanGestureRecognizer*)gestureRecognizer) translationInView:viewRootContent];
        if (fabs(translation.x) > fabs(translation.y)) {
            return YES;
        }
        return NO;
    } else {
        return NO;
    }
}
@end
