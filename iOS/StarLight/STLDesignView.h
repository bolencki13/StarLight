//
//  STLDesignView.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STLLightFrame, STLHub;
@interface STLDesignView : UIView
@property (nonatomic, retain) UIColor *drawColor;
@property (nonatomic, readonly) BOOL empty;
@property (nonatomic, readonly) BOOL drawing;
@property (nonatomic, retain, readonly) UIImage *image;
@property (nonatomic, retain) STLLightFrame *lightFrame;
@property (nonatomic, retain, readonly) NSIndexPath *size;
@property (nonatomic, copy) void (^didFinishDrawing)(UIImage *image, STLLightFrame *lightFrame);
+ (UIImage*)imageFromFrame:(STLLightFrame*)frame;
- (instancetype)initWithFrame:(CGRect)frame withFrame:(STLLightFrame*)lightFrame;
- (void)updateValuesForMatrixSize:(NSIndexPath*)size;
- (void)erase;
- (void)highlightAtIndex:(NSIndexPath*)indexPath;
@end
