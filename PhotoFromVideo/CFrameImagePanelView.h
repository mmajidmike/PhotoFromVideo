//
//  CFrameImagePanelView.h
//  VideoEdit
//
//  Created by mike majid on 2013-08-08.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


#define FRAME_PANEL_VIEW_LEFT_INSET 10
#define FRAME_PANEL_VIEW_RIGHT_INSET 10

@interface CFrameImagePanelView : UIView

@property (nonatomic) int videoWidth, videoHeight;
@property (nonatomic) BOOL frameGenerationComplete;
@property (nonatomic,retain) AVAsset* avasset;

- (void) viewDidRotate;
- (void) animateToFullScreenFinished;
- (void) displayVideoFrames;
- (void) cancelFrameGeneration;
- (void) removeAllFrameImageViews;
- (void) getImageAtTime:(double)seekTime withCallBack:(void (^)(UIImage* imageAtSeekTime))seekToTimeComplete;

@end
