//
//  BFViewController.h
//  CropDemo
//
//  Created by John Nichols on 2/28/13.
//  Copyright (c) 2013 John Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFCropInterface.h"

@interface BFViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *displayImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) BFCropInterface *cropper;

- (IBAction)cropPressed:(id)sender;
- (IBAction)originalPressed:(id)sender;

@end
