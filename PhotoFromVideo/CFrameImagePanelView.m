//
//  CFrameImagePanelView.m
//  VideoEdit
//
//  Created by mike majid on 2013-08-08.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CFrameImagePanelView.h"
#import <AVFoundation/AVAssetImageGenerator.h>
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

#define VIDEO_FRAME_VIEW_FULLSCREEN_HEIGHT 40

@interface CFrameImagePanelView ()

@property (nonatomic,retain) NSMutableArray* frameImageArray;
@property (nonatomic, retain) AVAssetImageGenerator* avassetImageGenerator;
@property (nonatomic) int iNumFrames;
@property (nonatomic) double iFrameWidth;
@property (nonatomic) double frameHeight;
@property (nonatomic) BOOL block_AddFrameImageSubViewDueToRotation;
@property (nonatomic) BOOL frameGenerationInProgress;

@end


@implementation CFrameImagePanelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor]; // [UIColor blueColor];
        self.frameGenerationInProgress = false;
        self.block_AddFrameImageSubViewDueToRotation = false;
        self.frameGenerationComplete = false;
        
    }
    return self;
}

- (void) dealloc;
{
    PRLog(@"");
}




- (void) viewDidRotate;
{
    [self displayVideoFrames];
}

- (void) animateToFullScreenFinished;
{
    [self displayVideoFrames];
}

- (void) displayVideoFrames;
{
    CGRect parentViewFrame = self.superview.frame;
    CGRect viewFrame = self.frame;
    viewFrame.origin.x = FRAME_PANEL_VIEW_LEFT_INSET;
    viewFrame.size.width = parentViewFrame.size.width - FRAME_PANEL_VIEW_LEFT_INSET - FRAME_PANEL_VIEW_RIGHT_INSET;
    self.frame = viewFrame;

    [self displayVideoFramesUsingAVAssetImageGenerator];
}

- (void) displayViewFrameUsingAudioData;
{
    PRLog(@"");
    [self setNeedsDisplay];
}

- (void) displayVideoFramesUsingAVAssetImageGenerator;
{
    if (self.frameImageArray) {
        [self displayVideoFramesFromFrameImageArray];
    }
    else {
        self.frameImageArray = [[NSMutableArray alloc] initWithCapacity:10];
        [self performSelectorInBackground:@selector(displayVideoFramesUsingAVAssetImageGenerator_bg) withObject:nil];
    }

}
- (void) removeAllFrameImageViews;
{
    NSArray* subViewArray = [self subviews];
    for (UIView* view in subViewArray) {
        if ([view isKindOfClass:[UIImageView class]]) [view removeFromSuperview];
    }
}
- (void) displayVideoFramesFromFrameImageArray;
{
    [self calculateDisplayedFrameParameters];
    [self removeAllFrameImageViews];
    int frameImageArrayCount = [self.frameImageArray count];
    PRLog(@"self.iNumFrames=%d frameImageArrayCount=%d", self.iNumFrames, frameImageArrayCount);
    for (int i=0 ; i<self.iNumFrames ; i++) {
        int frameIndex = ((double)i/(double)self.iNumFrames) * (double) frameImageArrayCount;
        if (frameIndex >= frameImageArrayCount) frameIndex = (frameImageArrayCount-1); // break;
        double w = self.iFrameWidth;
        double h = self.frameHeight;
        double x = w*i; // w*frameIndex;
        double y = 0;
        CGRect frameImageRect = CGRectMake(x, y, w, h);
        UIImageView* frameImageView = [self.frameImageArray objectAtIndex:frameIndex];
        UIImageView* imageViewToBeDisplayed = [[UIImageView alloc] initWithFrame:frameImageRect];
        imageViewToBeDisplayed.image = frameImageView.image;
        frameImageView.frame = frameImageRect;
        [self addSubview:imageViewToBeDisplayed];
    }
}
- (void) cancelFrameGeneration;
{
    PRLog(@"");
    if (self.avassetImageGenerator) {
        PRLog(@"cancelling");
        [self.avassetImageGenerator cancelAllCGImageGeneration];
    }

}
- (void) calculateDisplayedFrameParameters;
{
    double viewWidth = self.frame.size.width;
    double viewHeight = self.frame.size.height;
    self.frameHeight = viewHeight;
    double frameWidth = self.frameHeight; // self.frameHeight * videoAspectRatio;
    double numFrames = (double)viewWidth/frameWidth;
    PRLog(@"frame wh=(%g,%g) numFrames=%g", frameWidth, self.frameHeight, numFrames);
    self.iNumFrames = numFrames; // numFrames+1;
    self.iFrameWidth = frameWidth; // viewWidth/self.iNumFrames;
    PRLog(@"iNumFrames=%d iFrameWidth=%g", self.iNumFrames, self.iFrameWidth);
}
- (void) displayVideoFramesUsingAVAssetImageGenerator_bg;
{
    PRLog(@"");
    
    
    [self calculateDisplayedFrameParameters];
    if (true) {
        if (true) {
            AVAsset* avasset = self.avasset;
            if (avasset) {
                PRLog(@"Successfully obtained avasset");
                self.avassetImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avasset];
                self.avassetImageGenerator.appliesPreferredTrackTransform = YES;
                if (self.avassetImageGenerator) {
                    PRLog(@"Successfully generated avassetImageGenerator");
                    
                    double durationWithoutOffsets = CMTimeGetSeconds(avasset.duration); // CMTimeGetSeconds([vidElement getDurationWithoutOffsets]);
                    double durationPerFrame = durationWithoutOffsets/self.iNumFrames;
                    
                    NSMutableArray* requestedTimeArray = [[NSMutableArray alloc] initWithCapacity:10];
                    for (int i=0 ; i<self.iNumFrames ; i++) {
                        double playBackTime = i*durationPerFrame + (durationPerFrame/2.0);
                        CMTime sampleCMTime = CMTimeMakeWithSeconds(playBackTime, 1200);
                        [requestedTimeArray addObject:[NSValue valueWithCMTime:sampleCMTime]];
                    }
                    
                    __block int frameIndex = 0;
                    void (^AVAssetImageGeneratorCompletionHandler)(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) =
                    ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
                        if (result == AVAssetImageGeneratorSucceeded) {
                        
                            double w = self.iFrameWidth;
                            double h = self.frameHeight;
                            double x = w*frameIndex;
                            double y = 0;
                            CGRect frameImageRect = CGRectMake(x, y, w, h);
                            frameIndex++;
                        
                            UIImage* scaledImage = [self scaleImage:image toFit:frameImageRect.size];
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 UIImageView* frameImageView = [[UIImageView alloc] initWithImage:scaledImage]; // [GraphicsUtilities getImageViewFromFile:@"ApplyButton.png" x:0 y:0];
                                 frameImageView.frame = frameImageRect;
                                 [self.frameImageArray addObject:frameImageView];
                                 if (!self.block_AddFrameImageSubViewDueToRotation) [self addSubview:frameImageView];
                                 if (frameIndex == self.iNumFrames) [self frameGenerationFinished];
                             });
                        }
                    };
                    self.frameGenerationInProgress = true;
                    [self.avassetImageGenerator generateCGImagesAsynchronouslyForTimes:requestedTimeArray completionHandler:AVAssetImageGeneratorCompletionHandler];
                }
                else {
                    PRLog(@"Unable to create avassetImageGenerator");
                }
            }
            else {
                PRLog(@"Unable to obtain avasset");
            }
        }
        
    }
}
- (void) frameGenerationFinished;
{
    PRLog(@"");
    self.frameGenerationInProgress = false;
    if (self.block_AddFrameImageSubViewDueToRotation) {
        [self displayVideoFramesFromFrameImageArray];
        self.block_AddFrameImageSubViewDueToRotation = false;
    }
    self.frameGenerationComplete = true;
}

- (void) addImageToFrameView:(NSDictionary*)parameters;
{
    UIImage* scaledImage = (UIImage*)[parameters objectForKey:@"scaledImage"];
    CGRect frameImageRect = [[parameters objectForKey:@"frameImageRect"] CGRectValue];
    double rotAngle = [[parameters objectForKey:@"rotAngle"] doubleValue];
    UIImageView* frameImageView = [[UIImageView alloc] initWithImage:scaledImage]; // [GraphicsUtilities getImageViewFromFile:@"ApplyButton.png" x:0 y:0];
    frameImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    frameImageView.autoresizesSubviews = true;
    frameImageView.frame = frameImageRect;
    frameImageView.transform = CGAffineTransformMakeRotation(rotAngle); // preferredTransform;
    [self.frameImageArray addObject:frameImageView];
    [self addSubview:frameImageView];
}
- (UIImage*) scaleImage:(CGImageRef)imageRef toFit:(CGSize)newSize;
{
    UIImage* srcImage = [UIImage imageWithCGImage:imageRef];
    double imageWidth = srcImage.size.width;
    double imageHeight = srcImage.size.height;
    double cWidth = MIN(imageWidth, imageHeight);
    double cHeight = cWidth;
    double cx = (imageWidth - cWidth)/2.0;
    double cy = (imageHeight - cHeight)/2.0;
    UIImage* scaledImage = [self getCroppedScaledImage:cx cy:cy cWidth:cWidth cHeight:cHeight image:srcImage newSize:newSize];
    return scaledImage;
}

- (UIImage*) getCroppedScaledImage:(double)cx cy:(double)cy cWidth:(double)cWidth cHeight:(double)cHeight image:(UIImage*)image newSize:(CGSize)newSize {
    CGRect croppedRect = CGRectMake(cx,cy,cWidth,cHeight); // or whatever rectangle
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(image.CGImage, croppedRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
    
    BOOL scalingRequired = false;
    if (cWidth != newSize.width) scalingRequired = true;
    if (cHeight != newSize.height) scalingRequired = true;
    UIImage* scaledImage = croppedImage;
    
    if (scalingRequired) {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f); // UIGraphicsBeginImageContext( newSize );
        [croppedImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    CGImageRelease(croppedImageRef);
    
    return scaledImage;
}


- (void) getImageAtTime:(double)seekTime withCallBack:(void (^)(UIImage* imageAtSeekTime))imageReadyCallBack;
{
    PRLog(@"seekTime=%g", seekTime);
    
    if (self.avassetImageGenerator) {
        CMTime sampleCMTime = CMTimeMakeWithSeconds(seekTime, 1200);
        NSArray* requestedTimeArray = [NSArray arrayWithObject:[NSValue valueWithCMTime:sampleCMTime]];
        
        void (^AVAssetImageGeneratorCompletionHandler)(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) =
        ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
            if (result == AVAssetImageGeneratorSucceeded) {
                UIImage *imageAtSeekTime = [UIImage imageWithCGImage:image];
                if (imageReadyCallBack) {
                    imageReadyCallBack(imageAtSeekTime);
                }
            }
        };
        self.avassetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        self.avassetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        [self.avassetImageGenerator generateCGImagesAsynchronouslyForTimes:requestedTimeArray completionHandler:AVAssetImageGeneratorCompletionHandler];
    }
}

@end
