//
//  CVideoFrameView.m
//  VideoEdit.
//
//  Created by mike majid on 2013-08-06.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CVideoFrameView.h"
#import "UIImage+UIImage_getImage.h"

#import <QuartzCore/QuartzCore.h>

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

#define MIN_CURSOR_OFFSET 12
#define TOUCH_REGION_WIDTH 44
#define MINIMUM_FRAME_WIDTH 40
#define LEFT_RIGHT_MASK_ALPHA 0.7
#define SUB_PANEL_INITIAL_WIDTH_OFFSET 40

@interface CVideoFrameView ()
{
    BOOL dragCursor;
    BOOL dragLeftInset;
    BOOL dragRightInset;
}

@property (nonatomic) double subPanelWidthOffset;
@property (nonatomic, retain) UIView* subViewPanel;
@property (nonatomic,retain) UIView* leftMask;
@property (nonatomic,retain) UIView* rightMask;

@property (nonatomic) double cursor;
@property (nonatomic) double left;
@property (nonatomic) double right;

@end

@implementation CVideoFrameView

- (id)initWithFrame:(CGRect)frame
           delegate:(id <CVideoFrameViewDelegate>) delegate
    currentPlayTime:(double)currentPlayTime
             wScale:(double)wScale
            avasset:(AVAsset*)avasset
         videoWidth:(int)videoWidth
        videoHeight:(int)videoHeight;
{
    self = [super initWithFrame:frame];
    if (self) {
        PRLog(@"frame=(%g,%g,%g,%g)",frame.origin.x,frame.origin.y,frame.size.width,frame.size.width);
        [self initializeWithDelegate:delegate avasset:avasset videoWidth:videoWidth videoHeight:videoHeight];
    }
    return self;
}

- (void)initializeWithDelegate:(id <CVideoFrameViewDelegate>) delegate
            avasset:(AVAsset*)avasset
         videoWidth:(int)videoWidth
        videoHeight:(int)videoHeight;
{
    self.avasset = avasset;
    self.videoWidth = videoWidth;
    self.videoHeight = videoHeight;
    double startTimeOffset = 0;
    double endTimeOffset = 0;
    self.duration = CMTimeGetSeconds(avasset.duration);
    double rateScaledDuration = self.duration;
    double playBackRate = 1.0;
    double rateScaledStartTimeOffset = startTimeOffset/playBackRate;
    double rateScaledEndTimeOffset = endTimeOffset/playBackRate;
    double rateScaledDurationNoOffsets = rateScaledDuration + rateScaledStartTimeOffset + rateScaledEndTimeOffset;
    PRLog(@"startTimeOffset=%g", startTimeOffset);
    PRLog(@"endTimeOffset=%g", endTimeOffset);
    PRLog(@"rateScaledDuration=%g", rateScaledDuration);
    PRLog(@"playBackRate=%g", playBackRate);
    PRLog(@"rateScaledStartTimeOffset=%g", rateScaledStartTimeOffset);
    PRLog(@"rateScaledEndTimeOffset=%g", rateScaledEndTimeOffset);
    PRLog(@"rateScaledDurationNoOffsets=%g", rateScaledDurationNoOffsets);
    if (rateScaledDuration==0 || rateScaledDurationNoOffsets==0) {
        rateScaledDuration = 1;
        rateScaledDurationNoOffsets = 1;
    }
    self.backgroundColor = [UIColor clearColor]; // [UIColor grayColor]; // [UIColor grayColor];
    self.isTouchInside = false;
    self.subPanelWidthOffset = 0; // SUB_PANEL_INITIAL_WIDTH_OFFSET;
    
    self.layer.cornerRadius = 5; // 10; // 10;
    dragCursor = false;
    dragLeftInset = false;
    dragRightInset = false;
    self.durationHasBeenEdited = false;
    self.delegate = delegate;
    self.currentPlayTime = 0.0; // currentPlayTime;
    self.rightPadding = 0; // MIN_CURSOR_OFFSET + (CURSOR_WIDTH/2.0) + 6;
    self.leftPadding = 0; // (MIN_CURSOR_OFFSET + CURSOR_WIDTH/2.0);
    self.left = 0;
    self.right = 1.0;
    self.cursor = 0.5;
    
    // sub view panel
    CGRect frame = self.frame;
    CGRect subViewPanelFrame = frame;
    subViewPanelFrame.origin.x = 0;
    subViewPanelFrame.origin.y = 0;
    subViewPanelFrame.size.width = frame.size.width - self.subPanelWidthOffset; // *wScale;
    self.subViewPanel = [[UIView alloc] initWithFrame:subViewPanelFrame];
    self.subViewPanel.backgroundColor = [UIColor clearColor];
    self.subViewPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.subViewPanel.autoresizesSubviews = true;
    
    // scroll view frame
    double wScale = 1.0;
    double panelInsets = FRAME_PANEL_VIEW_LEFT_INSET + FRAME_PANEL_VIEW_RIGHT_INSET;
    UIImage* videoFrameScrollViewImage = [[UIImage GetImageFromFile:@"videoFrameScrollView.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    CGRect frameImageViewFrame = subViewPanelFrame;
    double fullFrameWidth = subViewPanelFrame.size.width - panelInsets*wScale;
    double frameImageViewWidth = fullFrameWidth*(rateScaledDuration/rateScaledDurationNoOffsets);
    frameImageViewFrame.origin.x = fullFrameWidth*(rateScaledStartTimeOffset/rateScaledDurationNoOffsets);;
    frameImageViewFrame.origin.y = 0;
    frameImageViewFrame.size.width = frameImageViewWidth + panelInsets*wScale;
    self.frameBorderImageView = [[UIImageView alloc] initWithFrame:frameImageViewFrame]; // [GraphicsUtilities getImageViewFromFile:@"videoFrameScrollView.png" x:0 y:0]; //
    self.frameBorderImageView.layer.cornerRadius = 5;
    self.frameBorderImageView.clipsToBounds = YES;
    self.frameBorderImageView.image = videoFrameScrollViewImage;
    self.frameBorderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.frameBorderImageView.autoresizesSubviews = true;
    self.frameBorderImageView.frame = frameImageViewFrame;
    
    // left mask
    CGRect leftMaskFrame = subViewPanelFrame;
    leftMaskFrame.origin.x = FRAME_PANEL_VIEW_LEFT_INSET*wScale;
    leftMaskFrame.origin.y = 0;
    leftMaskFrame.size.width = frameImageViewFrame.origin.x + VIDEO_FRAME_VIEW_CURSOR_WIDTH*wScale - FRAME_PANEL_VIEW_LEFT_INSET*wScale;
    self.leftMask = [[UIView alloc] initWithFrame:leftMaskFrame];
    self.leftMask.backgroundColor = [UIColor blackColor];
    self.leftMask.alpha = LEFT_RIGHT_MASK_ALPHA;
    self.leftMask.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.leftMask.autoresizesSubviews = true;
    
    // right mask
    CGRect rightMaskFrame = subViewPanelFrame;
    rightMaskFrame.origin.x = frameImageViewFrame.origin.x + frameImageViewFrame.size.width - VIDEO_FRAME_VIEW_CURSOR_WIDTH*wScale;
    rightMaskFrame.origin.y = 0;
    rightMaskFrame.size.width = subViewPanelFrame.size.width - rightMaskFrame.origin.x + VIDEO_FRAME_VIEW_CURSOR_WIDTH*wScale - FRAME_PANEL_VIEW_RIGHT_INSET*wScale;
    self.rightMask = [[UIView alloc] initWithFrame:rightMaskFrame];
    self.rightMask.backgroundColor = [UIColor blackColor];
    self.rightMask.alpha = LEFT_RIGHT_MASK_ALPHA;
    self.rightMask.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.rightMask.autoresizesSubviews = true;
    
    // cursor image
    double startTime = 0;
    double duration = self.duration;
    double timeStartEndRatio = 0.5;
    if ((self.currentPlayTime>=startTime) && (self.currentPlayTime<=(startTime+duration))) timeStartEndRatio = (self.currentPlayTime-startTime)/duration;
    double cursorX = frameImageViewFrame.origin.x + (frameImageViewFrame.size.width - panelInsets*wScale)*timeStartEndRatio + FRAME_PANEL_VIEW_LEFT_INSET*wScale;
    CGRect cursorImageViewFrame = subViewPanelFrame; // frame;
    cursorImageViewFrame.size.width = VIDEO_FRAME_VIEW_CURSOR_WIDTH;
    cursorImageViewFrame.origin.x = cursorX;
    cursorImageViewFrame.origin.y = 0; // (frame.size.height - cursorImageViewFrame.size.height)/2.0; // 0;
    UIImage* cursorImage = [UIImage GetImageFromFile:@"cursorVideoFrame.png"];
    PRLog(@"cursorImageViewFrame=(%g,%g,%g,%g)",cursorImageViewFrame.origin.x, cursorImageViewFrame.origin.y, cursorImageViewFrame.size.width, cursorImageViewFrame.size.height);
    self.cursorImageView = [[UIImageView alloc] initWithFrame:cursorImageViewFrame];
    self.cursorImageView.image = cursorImage;
    self.cursorImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.cursorImageView.autoresizesSubviews = true;
    self.cursorImageView.alpha = 0;
    
    // frameImagePanelView
    CGRect frameImagePanelViewFrame = subViewPanelFrame;
    frameImagePanelViewFrame.size.height = subViewPanelFrame.size.height; //  * 0.1;
    frameImagePanelViewFrame.size.width = subViewPanelFrame.size.width - (FRAME_PANEL_VIEW_LEFT_INSET+FRAME_PANEL_VIEW_RIGHT_INSET)*wScale;
    frameImagePanelViewFrame.origin.x = (subViewPanelFrame.size.width - frameImagePanelViewFrame.size.width)/2.0; //  0;
    frameImagePanelViewFrame.origin.y = (subViewPanelFrame.size.height - frameImagePanelViewFrame.size.height)/2.0; // 0;
    self.frameImagePanelView = [[CFrameImagePanelView alloc] initWithFrame:frameImagePanelViewFrame];
    self.frameImagePanelView.avasset = self.avasset;
    self.frameImagePanelView.videoWidth = self.videoWidth;
    self.frameImagePanelView.videoHeight = self.videoHeight;
    self.frameImagePanelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.frameImagePanelView.autoresizesSubviews = true;
    
    // add to view
    [self addSubview:self.subViewPanel];
    [self.subViewPanel addSubview:self.frameImagePanelView];
    [self.subViewPanel addSubview:self.leftMask];
    [self.subViewPanel addSubview:self.rightMask];
    [self.subViewPanel addSubview:self.frameBorderImageView];
    [self.subViewPanel addSubview:self.cursorImageView];
}

- (void) dealloc {
    PRLog(@"");
}

- (void) setVideoWidth:(int)videoWidth;
{
    _videoWidth = videoWidth;
    self.frameImagePanelView.videoWidth = videoWidth;
}
- (void) setVideoHeight:(int)videoHeight;
{
    _videoHeight = videoHeight;
    self.frameImagePanelView.videoHeight = videoHeight;
}

- (void) animateToFullScreenFinished;
{
    [self animateToFullScreenFinishedDisplayVideoFrames:YES];
}

- (void) animateToFullScreenFinishedDisplayVideoFrames:(BOOL)displayVideoFrames;
{
    CGRect viewFrame = self.frame;
    CGRect subViewPanelFrame = viewFrame;
    subViewPanelFrame.origin.x = 0;
    subViewPanelFrame.origin.y = 0;
    subViewPanelFrame.size.width = viewFrame.size.width - self.subPanelWidthOffset;
    self.subViewPanel.frame = subViewPanelFrame;
    
    double startTime = 0;
    double startTimeOffset = 0;
    double endTimeOffset = 0;
    double rateScaledDuration = self.duration;
    double playBackRate = 1.0;
    double cursorTime = self.currentPlayTime - startTime + startTimeOffset/playBackRate;
    double rateScaledStartTimeOffset = startTimeOffset/playBackRate;
    double rateScaledEndTimeOffset = endTimeOffset/playBackRate;
    double rateScaledDurationNoOffsets = rateScaledDuration + rateScaledStartTimeOffset + rateScaledEndTimeOffset;
    PRLog(@"currentPlayTime=%g", self.currentPlayTime);
    PRLog(@"startTime=%g", startTime);
    PRLog(@"cursorTime=%g", cursorTime);
    PRLog(@"startTimeOffset=%g", startTimeOffset);
    PRLog(@"endTimeOffset=%g", endTimeOffset);
    PRLog(@"rateScaledDuration=%g", rateScaledDuration);
    PRLog(@"playBackRate=%g", playBackRate);
    PRLog(@"rateScaledStartTimeOffset=%g", rateScaledStartTimeOffset);
    PRLog(@"rateScaledEndTimeOffset=%g", rateScaledEndTimeOffset);
    PRLog(@"rateScaledDurationNoOffsets=%g", rateScaledDurationNoOffsets);
    if (rateScaledDuration==0 || rateScaledDurationNoOffsets==0) {
        rateScaledDuration = 1;
        rateScaledDurationNoOffsets = 1;
    }
    
    // scroll view frame
    double panelInsets = FRAME_PANEL_VIEW_LEFT_INSET + FRAME_PANEL_VIEW_RIGHT_INSET;
    CGRect frameImageViewFrame = subViewPanelFrame;
    double fullFrameWidth = subViewPanelFrame.size.width - panelInsets;
    double frameImageViewWidth = fullFrameWidth*(rateScaledDuration/rateScaledDurationNoOffsets);
    frameImageViewFrame.origin.x = fullFrameWidth*(rateScaledStartTimeOffset/rateScaledDurationNoOffsets);;
    frameImageViewFrame.origin.y = 0;
    frameImageViewFrame.size.width = frameImageViewWidth + panelInsets;
    PRLog(@"frameImageViewFrame=(%g,%g,%g,%g)", frameImageViewFrame.origin.x, frameImageViewFrame.origin.y, frameImageViewFrame.size.width, frameImageViewFrame.size.height);
    self.frameBorderImageView.frame = frameImageViewFrame;
    
    [self ensureCursorIsBetweenLeftRightInsets:self.cursorImageView.frame];
    double cursorHeightScale = 1.18;
    CGRect cursorImageViewFrame = self.cursorImageView.frame;
    cursorImageViewFrame.size.height = cursorImageViewFrame.size.height*cursorHeightScale; // 46;
    cursorImageViewFrame.origin.y = (subViewPanelFrame.size.height - cursorImageViewFrame.size.height)/2.0;
    self.cursorImageView.frame = cursorImageViewFrame;
    if (displayVideoFrames) [self.frameImagePanelView animateToFullScreenFinished];
    
    self.cursorImageView.alpha = 1.0;
    [self setCursorPositionWithPlayTime:cursorTime];
}


- (void) viewDidRotate;
{
    PRLog(@"self.cursor=%g", self.cursor);
    
    CGRect viewFrame = self.frame;
    CGRect subViewPanelFrame = viewFrame;
    subViewPanelFrame.origin.x = 0;
    subViewPanelFrame.origin.y = 0;
    subViewPanelFrame.size.width = viewFrame.size.width - self.subPanelWidthOffset;
    self.subViewPanel.frame = subViewPanelFrame;
    
    double frameImagePanelWidth = subViewPanelFrame.size.width - FRAME_PANEL_VIEW_LEFT_INSET - FRAME_PANEL_VIEW_RIGHT_INSET;
    double cursorX = (self.cursor*frameImagePanelWidth) + FRAME_PANEL_VIEW_LEFT_INSET - (VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0);
    CGRect cursorImageViewFrame = self.cursorImageView.frame;
    cursorImageViewFrame.origin.x = cursorX;
    self.cursorImageView.frame = cursorImageViewFrame;
    
    double leftInset = self.left * frameImagePanelWidth;
    double rightInset = (self.right*frameImagePanelWidth) + FRAME_PANEL_VIEW_LEFT_INSET + FRAME_PANEL_VIEW_RIGHT_INSET;
    CGRect frameImageViewFrame = self.frameBorderImageView.frame;
    frameImageViewFrame.origin.x = leftInset;
    frameImageViewFrame.size.width = rightInset - leftInset; //  leftInset + rightInset;
    self.frameBorderImageView.frame = frameImageViewFrame;
    
    CGRect leftMaskFrame = self.leftMask.frame;
    leftMaskFrame.origin.x = FRAME_PANEL_VIEW_LEFT_INSET;
    leftMaskFrame.size.width = leftInset + FRAME_PANEL_VIEW_LEFT_INSET - FRAME_PANEL_VIEW_LEFT_INSET;
    self.leftMask.frame = leftMaskFrame;
    
    CGRect rightMaskFrame = self.rightMask.frame;
    rightMaskFrame.origin.x = frameImageViewFrame.size.width + frameImageViewFrame.origin.x - FRAME_PANEL_VIEW_RIGHT_INSET;
    rightMaskFrame.size.width = subViewPanelFrame.size.width - rightMaskFrame.origin.x - FRAME_PANEL_VIEW_RIGHT_INSET;
    self.rightMask.frame = rightMaskFrame;
    
    [self.frameImagePanelView viewDidRotate];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    // [super touchesBegan:touches withEvent:event];
    self.isTouchInside = true;
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    CGRect cursorImageViewFrame = self.cursorImageView.frame;
    double cursorX = cursorImageViewFrame.origin.x + (VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0);
    
    dragCursor = false;
    dragLeftInset = false;
    dragRightInset = false;
    double distanceToCursor = fabs(cursorX - touchPoint.x);
    if (distanceToCursor <= (TOUCH_REGION_WIDTH/2.0)) dragCursor = true;
    else {
        CGRect cursorImageViewFrame = self.cursorImageView.frame;
        double cursorX = touchPoint.x; //  - (CURSOR_WIDTH/2.0); // rightInset - MIN_CURSOR_OFFSET - CURSOR_WIDTH; // leftInset + MIN_CURSOR_OFFSET; // touchPoint.x;
        cursorImageViewFrame.origin.x = cursorX - (VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0);
        self.cursorImageView.frame = cursorImageViewFrame;
        [self ensureCursorIsBetweenLeftRightInsets:self.cursorImageView.frame];
        dragCursor = true;
    }
    PRLog(@"dragCursor=%d", dragCursor);
    PRLog(@"dragLeftInset=%d", dragLeftInset);
    PRLog(@"dragRightInset=%d", dragRightInset);
    
    if (self.delegate) [self.delegate CVideoFrameViewCursorTouchesBegan:self];
}
// /*****
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    CGRect subViewPanelFrame = self.subViewPanel.frame;
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    double leftInset = self.frameBorderImageView.frame.origin.x;
    double rightInset = self.frameBorderImageView.frame.origin.x + self.frameBorderImageView.frame.size.width;
    
    if (touchPoint.x > rightInset) {
        dragCursor = false;
    }
    if (touchPoint.x < leftInset) {
        dragCursor = false;
    }

    if (dragCursor) {
        CGRect cursorImageViewFrame = self.cursorImageView.frame;
        double cursorX = touchPoint.x; //  - (CURSOR_WIDTH/2.0); // rightInset - MIN_CURSOR_OFFSET - CURSOR_WIDTH; // leftInset + MIN_CURSOR_OFFSET; // touchPoint.x;
        cursorImageViewFrame.origin.x = cursorX - (VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0);
        self.cursorImageView.frame = cursorImageViewFrame;
    }
    else if (dragLeftInset) {
        CGRect frameImageViewFrame = self.frameBorderImageView.frame;
        double leftInset = touchPoint.x - FRAME_PANEL_VIEW_LEFT_INSET; // self.leftPadding;
        if (leftInset < 0) leftInset = 0;
        double rightInset = self.frameBorderImageView.frame.origin.x + self.frameBorderImageView.frame.size.width;
        if (rightInset - leftInset < MINIMUM_FRAME_WIDTH) leftInset = rightInset - MINIMUM_FRAME_WIDTH;
        double deltaWidth = frameImageViewFrame.origin.x - leftInset;
        frameImageViewFrame.origin.x = leftInset;
        frameImageViewFrame.size.width = frameImageViewFrame.size.width + deltaWidth;
        self.frameBorderImageView.frame = frameImageViewFrame;
        
        CGRect leftMaskFrame = self.leftMask.frame;
        leftMaskFrame.origin.x = FRAME_PANEL_VIEW_LEFT_INSET;
        leftMaskFrame.size.width = leftInset; //  + FRAME_PANEL_VIEW_LEFT_INSET ;
        self.leftMask.frame = leftMaskFrame;
        
        self.durationHasBeenEdited = true;
        [self switchToImageHasBeenEditedImage];
    }
    else if (dragRightInset) {
        CGRect frameImageViewFrame = self.frameBorderImageView.frame;
        double leftInset = frameImageViewFrame.origin.x;
        double rightInset = leftInset + frameImageViewFrame.size.width;
        double rightFrameEdge = subViewPanelFrame.size.width;
        double touchX = touchPoint.x;
        if (touchX > rightFrameEdge-FRAME_PANEL_VIEW_RIGHT_INSET) touchX = rightFrameEdge-FRAME_PANEL_VIEW_RIGHT_INSET;
        if (touchX - leftInset < (MINIMUM_FRAME_WIDTH-FRAME_PANEL_VIEW_RIGHT_INSET)) touchX = leftInset + (MINIMUM_FRAME_WIDTH-FRAME_PANEL_VIEW_RIGHT_INSET);
        double deltaWidth = touchX - rightInset;
        frameImageViewFrame.size.width = frameImageViewFrame.size.width + deltaWidth + FRAME_PANEL_VIEW_RIGHT_INSET;
        self.frameBorderImageView.frame = frameImageViewFrame;
        
        CGRect rightMaskFrame = self.rightMask.frame;
        rightMaskFrame.origin.x = frameImageViewFrame.size.width + frameImageViewFrame.origin.x - FRAME_PANEL_VIEW_RIGHT_INSET;
        rightMaskFrame.size.width = subViewPanelFrame.size.width - rightMaskFrame.origin.x - FRAME_PANEL_VIEW_RIGHT_INSET;
        self.rightMask.frame = rightMaskFrame;
        
        self.durationHasBeenEdited = true;
        [self switchToImageHasBeenEditedImage];
    }
    if (dragCursor || dragLeftInset || dragRightInset) {
        [self ensureCursorIsBetweenLeftRightInsets:self.cursorImageView.frame];
    }
    
    if (self.delegate) [self.delegate CVideoFrameViewCursorTouchesMoved:self];
}
// ****/
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if (dragCursor) {
        if (self.delegate) [self.delegate CVideoFrameViewCursorTouchesEnded:self];
        else PRLog(@"self.delegate is NIL");
    }
    
    dragCursor = false;
    dragLeftInset = false;
    dragRightInset = false;
    self.isTouchInside = false;
}

- (BOOL) isDraggingLeftRightInset;
{
    return dragLeftInset || dragRightInset;
}

- (void) switchToImageHasBeenEditedImage;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage* videoFrameScrollViewImage = [[UIImage GetImageFromFile:@"editedVideoFrameScrollView.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
        self.frameBorderImageView.image = videoFrameScrollViewImage;
        UIImage* cursorImage = [UIImage GetImageFromFile:@"editedCursorVideoFrame.png"];
        self.cursorImageView.image = cursorImage;
    });
}
- (void) ensureCursorIsBetweenLeftRightInsets:(CGRect)cursorImageViewFrame;
{
    CGRect frameImageViewFrame = self.frameBorderImageView.frame;
    // frameImageViewFrame = self.frameBorderImageView.frame;
    double leftInset = frameImageViewFrame.origin.x;
    double rightInset = leftInset + frameImageViewFrame.size.width;
    double cursorX = cursorImageViewFrame.origin.x;
    double leftPadding = FRAME_PANEL_VIEW_LEFT_INSET - VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0;
    double rightPadding = FRAME_PANEL_VIEW_RIGHT_INSET + VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0;
    
    if (cursorX - leftInset < leftPadding) {
        cursorX = leftInset + leftPadding;
        cursorImageViewFrame.origin.x = cursorX;
    }
    if (rightInset - cursorX < rightPadding) {
        cursorX = rightInset - rightPadding; //  - CURSOR_WIDTH/2.0 - (CURSOR_WIDTH/2.0);
        cursorImageViewFrame.origin.x = cursorX; //  - (CURSOR_WIDTH/2.0);
    }
    if (cursorX < leftInset) {
        cursorX = leftInset + VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0;
        cursorImageViewFrame.origin.x = cursorX; //  - (CURSOR_WIDTH/2.0);
    }
    self.cursorImageView.frame = cursorImageViewFrame;
    
    double frameImagePanelWidth = self.frameImagePanelView.frame.size.width;
    self.cursor = (cursorX + (VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0) - FRAME_PANEL_VIEW_LEFT_INSET)/frameImagePanelWidth;
    self.left = leftInset/frameImagePanelWidth;
    self.right = (rightInset - FRAME_PANEL_VIEW_LEFT_INSET - FRAME_PANEL_VIEW_RIGHT_INSET)/frameImagePanelWidth;
}


- (void) setCursorPositionWithPlayTime:(double)playTime;
{
    if (isnan(playTime)) return;
    
    double duration = self.duration; // CMTimeGetSeconds([self.iconComponentView2Element getDuration]);
    
    double viewWidth = self.frameImagePanelView.frame.size.width;
    double offsetRatio = (playTime/duration);
    double cursorX = offsetRatio*viewWidth + FRAME_PANEL_VIEW_LEFT_INSET - VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0;
    CGRect cursorImageViewFrame = self.cursorImageView.frame;
    cursorImageViewFrame.origin.x = cursorX;
    
    
    [self ensureCursorIsBetweenLeftRightInsets:cursorImageViewFrame];
}
- (double) getCursorPosition;
{
    double leftInset = self.frameBorderImageView.frame.origin.x; //  + FRAME_PANEL_VIEW_LEFT_INSET;
    double rightInset = leftInset + self.frameBorderImageView.frame.size.width - FRAME_PANEL_VIEW_LEFT_INSET - FRAME_PANEL_VIEW_RIGHT_INSET;
    double cursorImageViewX = self.cursorImageView.frame.origin.x - FRAME_PANEL_VIEW_LEFT_INSET + VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0;
    double cursorPosition = (cursorImageViewX-leftInset)/(rightInset - leftInset); // cursorImageViewX/frameImageViewWidth; // (cursorImageViewX-leftInset)/frameImageViewWidth;
    return cursorPosition;
}

- (void) setStartTimeOffset:(double)startTimeOffset endTimeOffset:(double)endTimeOffset withAnimation:(BOOL)withAnimation;
{
    PRLog(@"");
    
    double rateScaledDuration = self.duration; // CMTimeGetSeconds([self.iconComponentView2Element getRateScaledDuration]);
    double playBackRate = 1.0;
    
    double rateScaledStartTimeOffset = startTimeOffset/playBackRate;
    double rateScaledEndTimeOffset = endTimeOffset/playBackRate;
    double rateScaledDurationNoOffsets = rateScaledDuration + rateScaledStartTimeOffset + rateScaledEndTimeOffset;
    
    CGRect frame = self.frame;
    double panelInsets = FRAME_PANEL_VIEW_LEFT_INSET + FRAME_PANEL_VIEW_RIGHT_INSET;
    CGRect frameImageViewFrame = self.frameBorderImageView.frame;
    double fullFrameWidth = self.frameImagePanelView.frame.size.width; //  - panelInsets; // frame.size.width - panelInsets;
    double frameImageViewWidth = fullFrameWidth*(rateScaledDuration/rateScaledDurationNoOffsets);
    frameImageViewFrame.origin.x = fullFrameWidth*(rateScaledStartTimeOffset/rateScaledDurationNoOffsets);;
    frameImageViewFrame.origin.y = 0;
    frameImageViewFrame.size.width = frameImageViewWidth + panelInsets;
    
    // left mask
    CGRect leftMaskFrame = self.leftMask.frame;
    leftMaskFrame.origin.x = FRAME_PANEL_VIEW_LEFT_INSET; // 0;
    leftMaskFrame.origin.y = 0;
    leftMaskFrame.size.width = frameImageViewFrame.origin.x + VIDEO_FRAME_VIEW_CURSOR_WIDTH - FRAME_PANEL_VIEW_LEFT_INSET;
    
    // right mask
    CGRect rightMaskFrame = self.rightMask.frame;
    rightMaskFrame.origin.x = frameImageViewFrame.origin.x + frameImageViewFrame.size.width - VIDEO_FRAME_VIEW_CURSOR_WIDTH;
    rightMaskFrame.origin.y = 0;
    rightMaskFrame.size.width = frame.size.width - rightMaskFrame.origin.x + VIDEO_FRAME_VIEW_CURSOR_WIDTH - FRAME_PANEL_VIEW_RIGHT_INSET;

    if (withAnimation == false) {
        self.frameBorderImageView.frame = frameImageViewFrame;
        self.leftMask.frame = leftMaskFrame;
        self.rightMask.frame = rightMaskFrame;
        [self ensureCursorIsBetweenLeftRightInsets:self.cursorImageView.frame];
        [self switchToImageHasBeenEditedImage];
    }
    else {
        double animationDuration = 0.3;
        [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.frameBorderImageView.frame = frameImageViewFrame;
                         self.leftMask.frame = leftMaskFrame;
                         self.rightMask.frame = rightMaskFrame;
                         [self ensureCursorIsBetweenLeftRightInsets:self.cursorImageView.frame];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             PRLog(@"animation finished");
                             [self switchToImageHasBeenEditedImage];
                         }
                     }
         ];
    }
}

- (void) trimFromStartToCursor;
{
    PRLog(@"");
    
    CGRect frameImageViewFrame = self.frameBorderImageView.frame;
    // double leftInset = frameImageViewFrame.origin.x;
    CGRect cursorImageViewFrame = self.cursorImageView.frame;
    double cursorX = cursorImageViewFrame.origin.x;
    double leftPadding = FRAME_PANEL_VIEW_LEFT_INSET - VIDEO_FRAME_VIEW_CURSOR_WIDTH/2.0;
    
    double leftInset = cursorX - leftPadding;
    frameImageViewFrame.origin.x = leftInset;
    self.frameBorderImageView.frame = frameImageViewFrame;
}
- (void) trimFromCursorToEnd;
{
    PRLog(@"");
}
- (void) removeAllTrimOffsets;
{
    PRLog(@"");
}

- (void) cancelFrameGeneration;
{
    [self.frameImagePanelView cancelFrameGeneration];
}

#pragma mark CExtendDurationButtonViewDelegate method implementations
- (void) CExtendDurationButtonView_touchesUpInside:(id)sender;
{
    PRLog(@"");
    if (self.delegate) [self.delegate CExtendDurationButtonViewDelegate_touchesUpInside:self];
}

@end
