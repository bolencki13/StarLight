//
//  STLDesignView.h
//  StarLight
//
//  Created by Brian Olencki on 12/9/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NS2DArray, STLLightPattern, STLHub;
@interface STLDesignView : UIView
@property (nonatomic, readonly) BOOL drawing;
@property (nonatomic, retain, readonly) UIImage *image;
@property (nonatomic, retain, readonly) STLHub *hub;
@property (nonatomic, retain) NS2DArray *states;
@property (nonatomic, retain, readonly) STLLightPattern *lightPattern;
@property (nonatomic, copy) void (^didFinishDrawing)(UIImage *image, NS2DArray *states, STLLightPattern *lightPattern);
+ (UIImage*)imageFromStates:(NS2DArray*)states;
- (instancetype)initWithFrame:(CGRect)frame withHub:(STLHub*)hub withStates:(NS2DArray*)states;
- (void)updateValuesForMatrixSize:(NSIndexPath*)size;
- (void)erase;
- (void)highlightAtIndex:(NSIndexPath*)indexPath;
@end
