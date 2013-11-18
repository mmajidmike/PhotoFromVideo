//
//  CPlayerView.h
//  PhotoFromVideo
//
//  Created by mike majid on 2013-11-07.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol CPlayerViewDelegate <NSObject>
- (void) playerTimeUpate:(NSNumber*)nsTime;
- (void) playerViewTapGesture;
- (void) playerViewSwipeLeftGesture;
- (void) playerViewSwipeRightGesture;
@end


@interface CPlayerView : UIView
{
    BOOL isValidToMonitorPlayer;
}

@property (nonatomic) double duration;
@property (nonatomic, assign) id<CPlayerViewDelegate> delegate;
@property (nonatomic, retain) AVPlayer* player;
@property (nonatomic, retain) AVPlayerItem* playerItem;
@property (nonatomic) BOOL isPlaying;

- (void) setURL:(NSURL*)videoURL duration:(double)duration;
- (void) play;
- (void) pause;
- (void) releasePlayer;
- (void) setVideoPosition:(double) position;
- (void) seekToTime:(double)seekTime withCallBack:(void (^)())seekToTimeComplete;
- (double) getCurrentPlayTime;


@end
