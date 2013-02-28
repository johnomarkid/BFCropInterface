//
//  PRImageCropper.h
//  Pongr
//
//  Created by John Nichols on 12/21/12.
//  Copyright (c) 2012 Pongr Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFCropInterface : UIImageView {
    BOOL isPanning;
    NSInteger currentTouches;
    CGPoint panTouch;
    CGFloat scaleDistance;
    UIView *currentDragView; 
    
    UIView *topView;
    UIView *bottomView;
    UIView *leftView;
    UIView *rightView;
    
    UIView *topLeftView;
    UIView *topRightView;
    UIView *bottomLeftView;
    UIView *bottomRightView;
}
@property (nonatomic, assign) CGRect crop;
@property (nonatomic, strong) UIView *cropView;

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image;
- (UIImage*)getCroppedImage;

@end
