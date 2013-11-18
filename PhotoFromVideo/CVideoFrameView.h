//
//  CVideoFrameView.h
//  VideoEdit
//
//  Created by mike majid on 2013-08-06.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFrameImagePanelView.h"

#define VIDEO_FRAME_VIEW_FULLSCREEN_HEIGHT 40
#define VIDEO_FRAME_VIEW_CURSOR_WIDTH 6

@protocol CVideoFrameViewDelegate
- (void) CVideoFrameViewCursorTouchesEnded:(id) sender;
- (void) CVideoFrameViewCursorTouchesBegan:(id) sender;
- (void) CVideoFrameViewCursorTouchesMoved:(id) sender;
- (void) CExtendDurationButtonViewDelegate_touchesUpInside:(id)sender;
@end


@interface CVideoFrameView : UIView // <CExtendDurationButtonViewDelegate>

- (id)initWithFrame:(CGRect)frame
           delegate:(id <CVideoFrameViewDelegate>) delegate
    currentPlayTime:(double)currentPlayTime
             wScale:(double)wScale
            avasset:(AVAsset*)avasset
         videoWidth:(int)videoWidth
        videoHeight:(int)videoHeight;
- (void)initializeWithDelegate:(id <CVideoFrameViewDelegate>) delegate
                       avasset:(AVAsset*)avasset
                    videoWidth:(int)videoWidth
                   videoHeight:(int)videoHeight;
- (void) viewDidRotate;
- (void) animateToFullScreenFinished;
- (void) animateToFullScreenFinishedDisplayVideoFrames:(BOOL)displayVideoFrames;
- (void) setCursorPositionWithPlayTime:(double)playTime;
- (double) getCursorPosition;
- (void) setStartTimeOffset:(double)startTimeOffset endTimeOffset:(double)endTimeOffset withAnimation:(BOOL)withAnimation;
- (BOOL) isDraggingLeftRightInset;

- (void) trimFromStartToCursor;
- (void) trimFromCursorToEnd;
- (void) removeAllTrimOffsets;
- (void) cancelFrameGeneration;

@property (nonatomic) int videoWidth, videoHeight;
@property (nonatomic,retain) AVAsset* avasset;
@property (nonatomic) double currentPlayTime;
@property (nonatomic) double duration;
@property (nonatomic, assign) id <CVideoFrameViewDelegate> delegate;
@property (nonatomic, retain) UIImageView* frameBorderImageView;
@property (nonatomic, retain) UIImageView* cursorImageView;
@property (nonatomic, retain) CFrameImagePanelView* frameImagePanelView;
@property (nonatomic) BOOL durationHasBeenEdited;
@property (nonatomic) double leftPadding;
@property (nonatomic) double rightPadding;
@property (nonatomic) BOOL isTouchInside;

@end
