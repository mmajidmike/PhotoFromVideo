//
//  CExtractImageFromVideoViewController.h
//  PhotoFromVideo
//
//  Created by mike majid on 2013-11-07.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CPlayerView.h"
#import "CVideoFrameView.h"
#import "CTimeButtonTextField.h"


@interface CExtractImageFromVideoViewController : UIViewController
<
CPlayerViewDelegate,
CVideoFrameViewDelegate,
CTimeButtonTextFieldDelegate
>

// @property (nonatomic, assign) ALAsset* alasset;
@property (nonatomic, retain) NSURL* videoURL;

@property (weak, nonatomic) IBOutlet CPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UISlider *moviePositionSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet CTimeButtonTextField *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *fastForwardButton;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet CVideoFrameView *videoFrameView;

- (IBAction)moviePositionSlider_touchDown:(id)sender;
- (IBAction)moviePositionSlider_valueChanged:(id)sender;
- (IBAction)playButton_handler:(id)sender;
- (IBAction)rewindButton_touchDown:(id)sender;
- (IBAction)rewindButton_touchDownRepeat:(id)sender;
- (IBAction)fastForwardButton_touchDown:(id)sender;
- (IBAction)fastForwardButton_touchDownRepeat:(id)sender;
- (IBAction)selectButton_handler:(id)sender;

@end
