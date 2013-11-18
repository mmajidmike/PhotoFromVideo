//
//  CExtractImageFromVideoViewController.m
//  PhotoFromVideo
//
//  Created by mike majid on 2013-11-07.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CExtractImageFromVideoViewController.h"
#import "UIImage+UIImage_getImage.h"
#import "CFrameImagePanelView.h"
#import "PRP3BtnAlertView.h"
#import "CEditShareImageViewController.h"
#import "CServer.h"

#import "GlobalDebug.h"
#ifdef GLOBAL_DEBUG
#define LOCAL_DEBUG
#ifdef LOCAL_DEBUG
#define PRLog(...) NSLog(@"%s:%d %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define PRLog(...) do { } while (0)
#endif
#else
#define PRLog(...) do { } while (0)
#endif

// strings
#define TITLE NSLocalizedString(@"Video ", nil)
#define CANCEL NSLocalizedString(@"Cancel ", nil)
#define TIME_BUTTON__MESSAGE NSLocalizedString(@"Set time cursor to: ", nil)

#define SWIPE_TIME_DELTA 0.2
#define TOUCH_HOLD_TIME 0.5

@interface CExtractImageFromVideoViewController ()
{
    double rewindButtonTouchDownTime;
    double fastForwardTouchDownTime;
    BOOL viewHasAlreadyAppeared;
}

@property (nonatomic) double frameRate;


@end

@implementation CExtractImageFromVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc;
{
    PRLog(@"");
    [self.playerView releasePlayer];
    self.playerView.delegate = nil;
    self.playerView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = TITLE;
    
    viewHasAlreadyAppeared = false;
        
	// Do any additional setup after loading the view.
    double screenWidth = [[UIScreen mainScreen] bounds].size.width;
    double videoWidth = screenWidth; // defaultRepresentation.dimensions.width;
    double videoHeight = screenWidth; // defaultRepresentation.dimensions.height;
    PRLog(@"video wh=(%g,%g)", videoWidth, videoHeight);
    
    // UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonHandler)];
    CGFloat main = 200; // 221.0;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonHandler)];
    cancelButton.tintColor = [UIColor colorWithRed:main/255.0 green:7.0/255.0 blue:29.0/255.0 alpha:1];
    NSMutableArray* leftSideButtonArray = [[NSMutableArray alloc] initWithCapacity:2];
    [leftSideButtonArray addObject:cancelButton];
    self.navigationItem.leftBarButtonItems = leftSideButtonArray;
    
    self.playerView.delegate = self;
    NSURL* videoURL = self.videoURL; // self.alasset.defaultRepresentation.url;
    AVAsset* avasset = [AVAsset assetWithURL:videoURL];
    CMTime cmTimeDuration = avasset.duration;
    double duration = CMTimeGetSeconds(cmTimeDuration);
    [self.playerView setURL:videoURL duration:duration];
    
    self.frameRate = 10.0; // 24.0;
    NSArray* AVAssetTrackArray = [avasset tracksWithMediaType:AVMediaTypeVideo];
    if ([AVAssetTrackArray count] > 0) {
        AVAssetTrack* videoAssetTrack = [AVAssetTrackArray objectAtIndex:0];
        if (videoAssetTrack) {
            self.frameRate = videoAssetTrack.nominalFrameRate;
            CGSize naturalSize = videoAssetTrack.naturalSize;
            PRLog(@"naturalSize wh=(%g,%g)", naturalSize.width, naturalSize.height);
            videoWidth = naturalSize.width;
            videoHeight = naturalSize.height;
        }
    }
    
    self.timeButton.delegate = self;
    
    [self.videoFrameView initializeWithDelegate:self avasset:avasset videoWidth:videoWidth videoHeight:videoHeight];
    [self.view addSubview:self.videoFrameView];
}

- (void) cancelButtonHandler {
    PRLog(@"");
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated;
{
    if (!viewHasAlreadyAppeared) {
        [self.videoFrameView animateToFullScreenFinished];
        [self.playerView play];
    }
    viewHasAlreadyAppeared = true;
}

- (void) setPlayButtonImage;
{
    UIImage* playButtonImage;
    if (self.playerView.isPlaying) playButtonImage = [UIImage GetImageFromFile:@"PauseButton.png"];
    else playButtonImage = [UIImage GetImageFromFile:@"PlayButton.png"];
    [self.playButton setImage:playButtonImage forState:UIControlStateNormal];
}

#pragma mark - CPlayerViewDelegate method implementations
- (void) playerTimeUpate:(NSNumber*)nsTime;
{
    // PRLog(@"time=%g", [nsTime doubleValue]);
    double currentPlayTime = [nsTime doubleValue];
    if (!self.moviePositionSlider.touchInside) {
        double duration = self.playerView.duration;
        double value = currentPlayTime/duration;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.moviePositionSlider.value = value;
        });
    }
    if (!self.videoFrameView.isTouchInside) {
        [self.videoFrameView setCursorPositionWithPlayTime:currentPlayTime];
    }
    
    static BOOL previousPlayerIsPlaying = false;
    BOOL playerViewIsPlaying = self.playerView.isPlaying;
    if (playerViewIsPlaying != previousPlayerIsPlaying) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setPlayButtonImage];
        });
        previousPlayerIsPlaying = playerViewIsPlaying;
    }
    
    if (currentPlayTime<0) currentPlayTime = 0;
    NSString* timeText = [NSString stringWithFormat:@"%3.2f", currentPlayTime];
    [self.timeButton setText:timeText];
    
    if (self.rewindButton.isTouchInside && !self.playerView.isPlaying) {
        double currentTime = CACurrentMediaTime();
        if (currentTime > rewindButtonTouchDownTime + TOUCH_HOLD_TIME) {
            double seekTime = currentPlayTime - 1.0/self.frameRate;
            [self.playerView seekToTime:seekTime withCallBack:nil];
        }
    }
    if (self.fastForwardButton.isTouchInside && !self.playerView.isPlaying) {
        double currentTime = CACurrentMediaTime();
        if (currentTime > fastForwardTouchDownTime + TOUCH_HOLD_TIME) {
            double seekTime = currentPlayTime + 1.0/self.frameRate;
            [self.playerView seekToTime:seekTime withCallBack:nil];
        }
    }
}
- (void) playerViewTapGesture;
{
    PRLog(@"");
    [self togglePlayPause];
}
- (void) playerViewSwipeLeftGesture;
{
    PRLog(@"");
    if (self.playerView.isPlaying) [self.playerView pause];
    else {
        double currentPlayTime = [self.playerView getCurrentPlayTime];
        double seekTime = currentPlayTime + SWIPE_TIME_DELTA;
        [self.playerView seekToTime:seekTime withCallBack:nil];
    }
}
- (void) playerViewSwipeRightGesture;
{
    // PRLog(@"");
    if (self.playerView.isPlaying) [self.playerView pause];
    else {
        double currentPlayTime = [self.playerView getCurrentPlayTime];
        double seekTime = currentPlayTime - SWIPE_TIME_DELTA;
        [self.playerView seekToTime:seekTime withCallBack:nil];
    }
}

#pragma buttons, sliders handlers
- (IBAction)moviePositionSlider_touchDown:(id)sender {
    // PRLog(@"");
    [self.playerView pause];
}

- (IBAction)moviePositionSlider_valueChanged:(id)sender {
    double value = self.moviePositionSlider.value;
    [self.playerView setVideoPosition:value];
}

- (IBAction)playButton_handler:(id)sender {
    [self togglePlayPause];
}

- (IBAction)rewindButton_touchDown:(id)sender {
    // PRLog(@"");
    if (self.playerView.isPlaying) [self.playerView pause];
    else {
        double currentPlayTime = [self.playerView getCurrentPlayTime];
        double seekTime = currentPlayTime - 1.0/self.frameRate;
        [self.playerView seekToTime:seekTime withCallBack:nil];
    }
    rewindButtonTouchDownTime = CACurrentMediaTime();
}

- (IBAction)rewindButton_touchDownRepeat:(id)sender {
    // PRLog(@"");
}

- (IBAction)fastForwardButton_touchDown:(id)sender {
    // PRLog(@"");
    if (self.playerView.isPlaying) [self.playerView pause];
    else {
        double currentPlayTime = [self.playerView getCurrentPlayTime];
        double seekTime = currentPlayTime + 1.0/self.frameRate;
        [self.playerView seekToTime:seekTime withCallBack:nil];
    }
    fastForwardTouchDownTime = CACurrentMediaTime();
}

- (IBAction)fastForwardButton_touchDownRepeat:(id)sender {
}

- (IBAction)selectButton_handler:(id)sender {
    if (self.playerView.isPlaying) [self.playerView pause];
    double currentPlayTime = [self.playerView getCurrentPlayTime];
    void(^imageReadyCallBack)(UIImage* imageAtSeekTime) = ^(UIImage* imageAtSeekTime){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self launchEditShareImageViewController:imageAtSeekTime];
        });
    };
    [self.videoFrameView.frameImagePanelView getImageAtTime:currentPlayTime withCallBack:imageReadyCallBack];
}

- (void) launchEditShareImageViewController:(UIImage*)image;
{
    UIStoryboard *storyboard = self.storyboard;
    CEditShareImageViewController* editShareImageVC = [storyboard instantiateViewControllerWithIdentifier:@"CEditShareImageViewController"];
    editShareImageVC.image = image;
    [self.navigationController pushViewController:editShareImageVC animated:YES];
}


- (void) togglePlayPause;
{
    if (self.playerView.isPlaying) [self.playerView pause];
    else [self.playerView play];
}

#pragma mark - CVideoFrameViewDelegate method implementations
- (void) CVideoFrameViewCursorTouchesEnded:(id) sender;
{
    PRLog(@"");
}
- (void) CVideoFrameViewCursorTouchesBegan:(id) sender;
{
    double cursorPosition = [self.videoFrameView getCursorPosition];
    PRLog(@"cursorPosition=%g", cursorPosition);
    [self.playerView pause];
    [self.playerView setVideoPosition:cursorPosition];
}
- (void) CVideoFrameViewCursorTouchesMoved:(id) sender;
{
    double cursorPosition = [self.videoFrameView getCursorPosition];
    PRLog(@"cursorPosition=%g", cursorPosition);
    [self.playerView setVideoPosition:cursorPosition];
}
- (void) CExtendDurationButtonViewDelegate_touchesUpInside:(id)sender;
{
    PRLog(@"");
}

#pragma mark - CTimeButtonTextFieldDelegate method implementations
- (void)timeButtonTextField_actionHandler:(id) sender;
{
    PRLog(@"");
    
    [self.playerView pause];
    __weak __block CExtractImageFromVideoViewController* selfRef = self;
    NSString *title = [CServer getAppName];
    NSString* message = TIME_BUTTON__MESSAGE;
    NSString* cancelTitle = @"Cancel";
    NSString* otherTitle = @"Ok";
    NSString* btn3Title = nil;
    __block PRP3BtnAlertView* alert = [[PRP3BtnAlertView alloc] initWithTitle:title
                                                                              message:message
                                                                          cancelTitle:cancelTitle
                                                                          cancelBlock:^(void) {
                                                                              PRLog(@"Cancel");
                                                                              alert = nil;
                                                                          }
                                                                           otherTitle:otherTitle
                                                                           otherBlock:^(void) {
                                                                               NSString* timeText = [alert textFieldAtIndex:0].text;
                                                                               double newTime = [timeText doubleValue];
                                                                               PRLog(@"Ok timeText=%@ newTime=%g", timeText,newTime);
                                                                               // [selfRef performSelectorOnMainThread:@selector(pauseAtNsTime:) withObject:[NSNumber numberWithDouble:newTime] waitUntilDone:NO];
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   [selfRef.playerView seekToTime:newTime withCallBack:nil];
                                                                               });
                                                                               alert = nil;
                                                                           }
                                                                            btn3Title:btn3Title
                                                                            btn3Block:^(void) {
                                                                                PRLog(@"btn3Block");
                                                                                alert = nil;
                                                                            }
                                               ];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
    [alert textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
    [alert textFieldAtIndex:0].text = self.timeButton.textField.text; // self.toolBarTimeButton.title;
    [alert show];
}

@end
