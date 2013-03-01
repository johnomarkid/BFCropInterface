//
//  BFCropInterface.m
//
//  Created by John Nichols on 12/21/12.

//Copyright (c) 2013 John Nichols "john@bitfountaincode.com"
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is furnished
//to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "BFCropInterface.h"
#import <QuartzCore/QuartzCore.h>

#define IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE 40.0f
#define IMAGE_CROPPER_INSIDE_STILL_EDGE 20.0f

#ifndef CGWidth
#define CGWidth(rect)                   rect.size.width
#endif

#ifndef CGHeight
#define CGHeight(rect)                  rect.size.height
#endif

#ifndef CGOriginX
#define CGOriginX(rect)                 rect.origin.x
#endif

#ifndef CGOriginY
#define CGOriginY(rect)                 rect.origin.y
#endif

@implementation BFCropInterface

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.userInteractionEnabled = YES;

        // set image to crop
        self.image = image;

        topView = [self newEdgeView];
        bottomView = [self newEdgeView];
        leftView = [self newEdgeView];
        rightView = [self newEdgeView];
        topLeftView = [self newCornerView];
        topRightView = [self newCornerView];
        bottomLeftView = [self newCornerView];
        bottomRightView = [self newCornerView];
        
        [self initialCropView];
    }
    return self;
}

- (void)initialCropView {
    CGFloat width;
    CGFloat height;
    CGFloat x;
    CGFloat y;
    
    width  = self.frame.size.width / 4 * 3;
    height = self.frame.size.height / 4 * 3;
    x      = (self.frame.size.width - width) / 2;
    y      = (self.frame.size.height - height) / 2;
    
    UIView* cropView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    cropView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cropView.layer.borderColor = [[UIColor whiteColor] CGColor];
    cropView.layer.borderWidth = 1.0;
    cropView.backgroundColor = [UIColor clearColor];
    
    UIImage *nodeImage = [UIImage imageNamed:@"node.png"];
    UIImageView *tlnode = [[UIImageView alloc]initWithImage:nodeImage];
    UIImageView *trnode = [[UIImageView alloc]initWithImage:nodeImage];
    UIImageView *blnode = [[UIImageView alloc]initWithImage:nodeImage];
    UIImageView *brnode = [[UIImageView alloc]initWithImage:nodeImage];
    tlnode.frame = CGRectMake(cropView.bounds.origin.x - 13, cropView.bounds.origin.y -13, 26, 26);
    trnode.frame = CGRectMake(cropView.frame.size.width - 13, cropView.bounds.origin.y -13, 26, 26);
    blnode.frame = CGRectMake(cropView.bounds.origin.x - 13, cropView.frame.size.height - 13, 26, 26);
    brnode.frame = CGRectMake(cropView.frame.size.width - 13, cropView.frame.size.height - 13, 26, 26);
    
    tlnode.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    trnode.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    blnode.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    brnode.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [cropView addSubview:tlnode];
    [cropView addSubview:trnode];
    [cropView addSubview:blnode];
    [cropView addSubview:brnode];
    
    self.cropView = cropView;
    [self addSubview:self.cropView];
    
    [self updateBounds];
}

#pragma mark - setters

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    topView.backgroundColor = _shadowColor;
    bottomView.backgroundColor = _shadowColor;
    leftView.backgroundColor = _shadowColor;
    rightView.backgroundColor = _shadowColor;
    topLeftView.backgroundColor = _shadowColor;
    topRightView.backgroundColor = _shadowColor;
    bottomLeftView.backgroundColor = _shadowColor;
    bottomRightView.backgroundColor = _shadowColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.cropView.layer.borderColor = _borderColor.CGColor;
}

#pragma mark - motion

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrt(x * x + y * y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self willChangeValueForKey:@"crop"];
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count]) {
        case 1: {
            currentTouches = 1;
            isPanning = NO;
            CGFloat insetAmount = IMAGE_CROPPER_INSIDE_STILL_EDGE;
            
            CGPoint touch = [[allTouches anyObject] locationInView:self];
            if (CGRectContainsPoint(CGRectInset(self.cropView.frame, insetAmount, insetAmount), touch)) {
                isPanning = YES;
                panTouch = touch;
                return;
            }
            
            CGRect frame = self.cropView.frame;
            CGFloat x = touch.x;
            CGFloat y = touch.y;
            
            currentDragView = nil;
            
            // We start dragging if we're within the rect + the inset amount
            // If we're definitively in the rect we actually start moving right to the point
            if (CGRectContainsPoint(CGRectInset(topLeftView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = topLeftView;
                
                if (CGRectContainsPoint(topLeftView.frame, touch)) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin = touch;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(topRightView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = topRightView;
                
                if (CGRectContainsPoint(topRightView.frame, touch)) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                    frame.size.width = x - CGOriginX(frame);
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomLeftView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = bottomLeftView;
                
                if (CGRectContainsPoint(bottomLeftView.frame, touch)) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height = y - CGOriginY(frame);
                    frame.origin.x =x;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomRightView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = bottomRightView;
                
                if (CGRectContainsPoint(bottomRightView.frame, touch)) {
                    frame.size.width = x - CGOriginX(frame);
                    frame.size.height = y - CGOriginY(frame);
                }
            }
            else if (CGRectContainsPoint(CGRectInset(topView.frame, 0, -insetAmount), touch)) {
                currentDragView = topView;
                
                if (CGRectContainsPoint(topView.frame, touch)) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomView.frame, 0, -insetAmount), touch)) {
                currentDragView = bottomView;
                
                if (CGRectContainsPoint(bottomView.frame, touch)) {
                    frame.size.height = y - CGOriginY(frame);
                }
            }
            else if (CGRectContainsPoint(CGRectInset(leftView.frame, -insetAmount, 0), touch)) {
                currentDragView = leftView;
                
                if (CGRectContainsPoint(leftView.frame, touch)) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.origin.x = x;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(rightView.frame, -insetAmount, 0), touch)) {
                currentDragView = rightView;
                
                if (CGRectContainsPoint(rightView.frame, touch)) {
                    frame.size.width = x - CGOriginX(frame);
                }
            }
            
            self.cropView.frame = frame;
            
            [self updateBounds];
            
            break;
        }
        case 2: {
            CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self];
            CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self];
            
            if (currentTouches == 0 && CGRectContainsPoint(self.cropView.frame, touch1) && CGRectContainsPoint(self.cropView.frame, touch2)) {
                isPanning = YES;
            }
            
            currentTouches = [allTouches count];
            break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self willChangeValueForKey:@"crop"];
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
    {
        case 1: {
            CGPoint touch = [[allTouches anyObject] locationInView:self];
            
            if (isPanning) {
                CGPoint touchCurrent = [[allTouches anyObject] locationInView:self];
                CGFloat x = touchCurrent.x - panTouch.x;
                CGFloat y = touchCurrent.y - panTouch.y;
                
                self.cropView.center = CGPointMake(self.cropView.center.x + x, self.cropView.center.y + y);
                
                panTouch = touchCurrent;
            }
            else if ((CGRectContainsPoint(self.bounds, touch))) {
                CGRect frame = self.cropView.frame;
                CGFloat x = touch.x;
                CGFloat y = touch.y;
                
                if (x > self.frame.size.width)
                    x = self.frame.size.width;
                
                if (y > self.frame.size.height)
                    y = self.frame.size.height;
                
                if (currentDragView == topView) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                }
                else if (currentDragView == bottomView) {
                    //currentDragView = bottomView;
                    frame.size.height = y - CGOriginY(frame);
                }
                else if (currentDragView == leftView) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.origin.x = x;
                }
                else if (currentDragView == rightView) {
                    //currentDragView = rightView;
                    frame.size.width = x - CGOriginX(frame);
                }
                else if (currentDragView == topLeftView) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin = touch;
                }
                else if (currentDragView == topRightView) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                    frame.size.width = x - CGOriginX(frame);
                }
                else if (currentDragView == bottomLeftView) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height = y - CGOriginY(frame);
                    frame.origin.x =x;
                }
                else if ( currentDragView == bottomRightView) {
                    frame.size.width = x - CGOriginX(frame);
                    frame.size.height = y - CGOriginY(frame);
                }
                
                self.cropView.frame = frame;
            }
        } break;
        case 2: {
            CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self];
            CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self];
            
            if (isPanning) {
                CGFloat distance = [self distanceBetweenTwoPoints:touch1 toPoint:touch2];
                
                if (scaleDistance != 0) {
                    CGFloat scale = 1.0f + ((distance-scaleDistance)/scaleDistance);
                    
                    CGPoint originalCenter = self.cropView.center;
                    CGSize originalSize = self.cropView.frame.size;
                    
                    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
                    
                    if (newSize.width >= 50 && newSize.height >= 50 && newSize.width <= CGWidth(self.cropView.superview.frame) && newSize.height <= CGHeight(self.cropView.superview.frame)) {
                        self.cropView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
                        self.cropView.center = originalCenter;
                    }
                }
                
                scaleDistance = distance;
            }
            else if (
                     currentDragView == topLeftView ||
                     currentDragView == topRightView ||
                     currentDragView == bottomLeftView ||
                     currentDragView == bottomRightView
                     ) {
                CGFloat x = MIN(touch1.x, touch2.x);
                CGFloat y = MIN(touch1.y, touch2.y);
                
                CGFloat width = MAX(touch1.x, touch2.x) - x;
                CGFloat height = MAX(touch1.y, touch2.y) - y;
                
                self.cropView.frame = CGRectMake(x, y, width, height);
            }
            else if (
                     currentDragView == topView ||
                     currentDragView == bottomView
                     ) {
                CGFloat y = MIN(touch1.y, touch2.y);
                CGFloat height = MAX(touch1.y, touch2.y) - y;
                
                // sometimes the multi touch gets in the way and registers one finger as two quickly
                // this ensures the crop only shrinks a reasonable amount all at once
                if (height > 30 || self.cropView.frame.size.height < 45)
                {
                    self.cropView.frame = CGRectMake(CGOriginX(self.cropView.frame), y, CGWidth(self.cropView.frame), height);
                }
            }
            else if (
                     currentDragView == leftView ||
                     currentDragView == rightView
                     ) {
                CGFloat x = MIN(touch1.x, touch2.x);
                CGFloat width = MAX(touch1.x, touch2.x) - x;
                
                // sometimes the multi touch gets in the way and registers one finger as two quickly
                // this ensures the crop only shrinks a reasonable amount all at once
                if (width > 30 || self.cropView.frame.size.width < 45)
                {                self.cropView.frame = CGRectMake(x, CGOriginY(self.cropView.frame), width, CGHeight(self.cropView.frame));
                }
            }
        } break;
    }
    
    [self updateBounds];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    scaleDistance = 0;
    currentTouches = [[event allTouches] count];
}

- (UIImage*)getCroppedImage {
    CGRect rect = self.cropView.frame;
    CGRect drawRect = [self cropRectForFrame:rect];
    UIImage *croppedImage = [self imageByCropping:self.image toRect:drawRect];
    
    return croppedImage;
}

- (UIImage *)imageByCropping:(UIImage *)image toRect:(CGRect)rect
{
    if (UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(rect.size,
                                               /* opaque */ NO,
                                               /* scaling factor */ 0.0);
    } else {
        UIGraphicsBeginImageContext(rect.size);
    }
    
    // stick to methods on UIImage so that orientation etc. are automatically
    // dealt with for us
    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

-(CGRect)cropRectForFrame:(CGRect)frame
{
    NSAssert(self.contentMode == UIViewContentModeScaleAspectFit, @"content mode must be aspect fit");
    
    CGFloat widthScale = self.bounds.size.width / self.image.size.width;
    CGFloat heightScale = self.bounds.size.height / self.image.size.height;
    
    float x, y, w, h, offset;
    if (widthScale<heightScale) {
        offset = (self.bounds.size.height - (self.image.size.height*widthScale))/2;
        x = frame.origin.x / widthScale;
        y = (frame.origin.y-offset) / widthScale;
        w = frame.size.width / widthScale;
        h = frame.size.height / widthScale;
    } else {
        offset = (self.bounds.size.width - (self.image.size.width*heightScale))/2;
        x = (frame.origin.x-offset) / heightScale;
        y = frame.origin.y / heightScale;
        w = frame.size.width / heightScale;
        h = frame.size.height / heightScale;
    }
    return CGRectMake(x, y, w, h);
}

- (void)updateBounds {
    [self constrainCropToImage];
    
    CGRect frame = self.cropView.frame;
    CGFloat x = CGOriginX(frame);
    CGFloat y = CGOriginY(frame);
    CGFloat width = CGWidth(frame);
    CGFloat height = CGHeight(frame);
    
    CGFloat selfWidth = CGWidth(self.frame);
    CGFloat selfHeight = CGHeight(self.frame);
    
    topView.frame = CGRectMake(x, 0, width , y);
    bottomView.frame = CGRectMake(x, y + height, width, selfHeight - y - height);
    leftView.frame = CGRectMake(0, y, x + 1, height);
    rightView.frame = CGRectMake(x + width, y, selfWidth - x - width, height);
    
    topLeftView.frame = CGRectMake(0, 0, x, y);
    topRightView.frame = CGRectMake(x + width, 0, selfWidth - x - width, y);
    bottomLeftView.frame = CGRectMake(0, y + height, x, selfHeight - y - height);
    bottomRightView.frame = CGRectMake(x + width, y + height, selfWidth - x - width, selfHeight - y - height);
    
    [self didChangeValueForKey:@"crop"];
}

- (void)constrainCropToImage {
    CGRect frame = self.cropView.frame;
    
    if (CGRectEqualToRect(frame, CGRectZero)) return;
    
    BOOL change = NO;
    
    do {
        change = NO;
        
        if (CGOriginX(frame) < 0) {
            frame.origin.x = 0;
            change = YES;
        }
        
        if (CGWidth(frame) > CGWidth(self.cropView.superview.frame)) {
            frame.size.width = CGWidth(self.cropView.superview.frame);
            change = YES;
        }
        
        if (CGWidth(frame) < 20) {
            frame.size.width = 20;
            change = YES;
        }
        
        if (CGOriginX(frame) + CGWidth(frame) > CGWidth(self.cropView.superview.frame)) {
            frame.origin.x = CGWidth(self.cropView.superview.frame) - CGWidth(frame);
            change = YES;
        }
        
        if (CGOriginY(frame) < 0) {
            frame.origin.y = 0;
            change = YES;
        }
        
        if (CGHeight(frame) > CGHeight(self.cropView.superview.frame)) {
            frame.size.height = CGHeight(self.cropView.superview.frame);
            change = YES;
        }
        
        if (CGHeight(frame) < 20) {
            frame.size.height = 20;
            change = YES;
        }
        
        if (CGOriginY(frame) + CGHeight(frame) > CGHeight(self.cropView.superview.frame)) {
            frame.origin.y = CGHeight(self.cropView.superview.frame) - CGHeight(frame);
            change = YES;
        }
    } while (change);
    
    self.cropView.frame = frame;
}

- (UIView*)newEdgeView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
    [self addSubview:view];
    return view;
}

- (UIView*)newCornerView {
    UIView *view = [self newEdgeView];
    view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
    return view;
}

@end
