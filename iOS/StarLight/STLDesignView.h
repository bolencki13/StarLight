//
//  STLDesignView.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLDesignView : UIView
@property (nonatomic, readonly) BOOL drawing;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy) void (^didFinishDrawing)(UIImage *image);
- (instancetype)initWithFrame:(CGRect)frame withImage:(UIImage*)image;
- (void)updateValuesForMatrixSize:(CGSize)size;
- (void)erase;
@end
