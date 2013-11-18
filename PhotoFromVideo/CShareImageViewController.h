//
//  CShareImageViewController.h
//  PhotoFromVideo
//
//  Created by mike majid on 2013-11-11.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <FacebookSDK/FacebookSDK.h>

@interface CShareImageViewController : UIViewController
<
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate
>

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIButton *iMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *faceBookButton;

@property (nonatomic, retain) UIImage* image;

- (IBAction)cameraButton_handler:(id)sender;
- (IBAction)mailButton_handler:(id)sender;
- (IBAction)iMessageButton_handler:(id)sender;
- (IBAction)faceBookButton_handler:(id)sender;

@end
