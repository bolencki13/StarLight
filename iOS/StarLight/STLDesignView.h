//
//  STLDesignView.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NS2DArray;
@interface STLDesignView : UIView
@property (nonatomic, readonly) BOOL drawing;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain, readonly) NS2DArray *states;
@property (nonatomic, copy) void (^didFinishDrawing)(UIImage *image, NS2DArray *states);
- (instancetype)initWithFrame:(CGRect)frame withImage:(UIImage*)image withStates:(NS2DArray*)states;
- (void)updateValuesForMatrixSize:(NSIndexPath*)size;
- (void)erase;
- (void)highlightAtIndex:(NSIndexPath*)indexPath;
@end
