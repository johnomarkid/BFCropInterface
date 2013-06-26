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

@property (weak, nonatomic) IBOutlet BFCropInterface *imageToCrop;

@property (nonatomic, strong) UIImage *originalImage;


- (IBAction)cropPressed:(id)sender;
- (IBAction)originalPressed:(id)sender;

@end
