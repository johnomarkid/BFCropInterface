//
//  BFViewController.m
//  CropDemo
//
//  Created by John Nichols on 2/28/13.
//  Copyright (c) 2013 John Nichols. All rights reserved.
//

#import "BFViewController.h"

@interface BFViewController ()

@end

@implementation BFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // make your image view content mode == aspect fit
    // yields best results
    self.displayImage.contentMode = UIViewContentModeScaleAspectFit;
    
    // must have user interaction enabled on view that will hold crop interface
    self.displayImage.userInteractionEnabled = YES;
    self.displayImage.frame = CGRectMake(20, 20, 280, 360);
    self.originalImage = [UIImage imageNamed:@"dumbo.jpg"];
    self.displayImage.image = self.originalImage;

    // allocate crop interface with frame and image being cropped
    self.cropper = [[BFCropInterface alloc]initWithFrame:self.displayImage.bounds andImage:self.originalImage];
    
    // add interface to superview. here we are covering the main image view.
    [self.displayImage addSubview:self.cropper];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cropPressed:(id)sender {
    // crop image
    UIImage *croppedImage = [self.cropper getCroppedImage];
    
    // remove crop interface from superview
    [self.cropper removeFromSuperview];
    self.cropper = nil;
    
    // display new cropped image
    self.displayImage.image = croppedImage;
}

- (IBAction)originalPressed:(id)sender {
    // set main image view to original image and add cropper if not already added
    self.displayImage.image = self.originalImage;
    if (!self.cropper) {
        self.cropper = [[BFCropInterface alloc]initWithFrame:self.displayImage.bounds andImage:self.originalImage];
        [self.displayImage addSubview:self.cropper];
    }
}

@end
