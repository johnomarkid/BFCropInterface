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
    
    // must have user interaction enabled on view that will hold crop interface

    

}

-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    self.originalImage = [UIImage imageNamed:@"dumbo.jpg"];

    // ** this is where the magic happens

    // allocate crop interface with frame and image being cropped
    // this is the default color even if you don't set it
    self.imageToCrop.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.60];
    // white is the default border color.
    self.imageToCrop.borderColor = [UIColor whiteColor];

    self.imageToCrop.image = self.originalImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cropPressed:(id)sender {
    
    // crop image
    UIImage *croppedImage = [self.imageToCrop getCroppedImage];
    
    // remove crop interface from superview
    
    // display new cropped image
    self.imageToCrop.image = croppedImage;
}

- (IBAction)originalPressed:(id)sender {
    // set main image view to original image and add cropper if not already added
    self.imageToCrop.image = self.originalImage;
    
}

@end
