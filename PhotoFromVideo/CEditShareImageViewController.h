//
//  CEditShareImageViewController.h
//  PhotoFromVideo
//
//  Created by mike majid on 2013-11-11.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFPhotoEditorController.h"

@interface CEditShareImageViewController : UIViewController <AFPhotoEditorControllerDelegate>

@property(nonatomic,retain) UIImage* image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)editButton_handler:(id)sender;
- (IBAction)shareButton_handler:(id)sender;

@end
