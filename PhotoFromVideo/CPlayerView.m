//
//  CPlayerView.m
//  PhotoFromVideo
//
//  Created by mike majid on 2013-11-07.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CPlayerView.h"

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

#define PLAYER_MONITOR_PERIOD 0.05



@implementation CPlayerView

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib;
{
    self.isPlaying = false;
    isValidToMonitorPlayer = false;
    
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightGestureHandler:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftGestureHandler:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void) dealloc;
{
    self.delegate = nil;
    PRLog(@"");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - gesture recognizers
- (void)swipeRightGestureHandler:(UILongPressGestureRecognizer *)recognizer {
    // PRLog(@"");
    if (self.delegate) {
        [self.delegate playerViewSwipeRightGesture];
    }
}

- (void)swipeLeftGestureHandler:(UILongPressGestureRecognizer *)recognizer {
    // PRLog(@"");
    if (self.delegate) {
        [self.delegate playerViewSwipeLeftGesture];
    }
}
- (void)tapGestureHandler:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // PRLog(@"");
        if (self.delegate) {
            [self.delegate playerViewTapGesture];
        }
    }
}



#pragma mark-playerView methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    PRLog(@"keyPath=%@", keyPath);
    
    if (object == _player) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PRLog(@"player status=%d", _player.status);
            [_player removeObserver:self forKeyPath:@"status"];
            [self startPlayingAfterPlayerReady];
        });
    }
}

- (void) startPlayingAfterPlayerReady;
{
    PRLog(@"");
    AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    CGRect targetViewFrame = self.frame;
    targetViewFrame.origin.x = 0;
    targetViewFrame.origin.y = 0;
    playerLayer.frame = targetViewFrame; // targetView.frame;
    [(AVPlayerLayer*)[self layer] setPlayer:self.player];
    
    // [self play];
}

- (void) setURL:(NSURL*)videoURL duration:(double)duration;
{
    self.duration = duration;
    self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    if (self.player.status != AVPlayerItemStatusReadyToPlay) {
        [_player addObserver:self forKeyPath:@"status" options:0 context:NULL];
    }
    else {
        [self startPlayingAfterPlayerReady];
    }
    [self performSelectorInBackground:@selector(monitorPlayerTime_bg) withObject:nil];
}

- (AVPlayer*) getPlayer {
    AVPlayer* player = ((AVPlayerLayer*)[self layer]).player;
    return player;
}
- (double) getCurrentPlayTime;
{
    AVPlayer* player = [self getPlayer];
    double currentPlayTime = CMTimeGetSeconds(player.currentTime);
    return currentPlayTime;
}

- (void) setVideoPosition:(double) position;
{
    AVPlayer* player = [self getPlayer];
    if (player) {
        [self seekToTime:(position*self.duration) withCallBack:nil];
    }
}

- (void) seekToTime:(double)seekTime withCallBack:(void (^)())seekToTimeComplete;
{
    AVPlayer* player = [self getPlayer];
    CMTime tolerance = kCMTimeZero; // CMTimeMake(1, _timescale);
    double sanitizedSeekTime = seekTime;
    if (sanitizedSeekTime < 0) sanitizedSeekTime = 0;
    if (sanitizedSeekTime > self.duration) sanitizedSeekTime = self.duration;
    [player seekToTime:CMTimeMakeWithSeconds(sanitizedSeekTime, 1200) toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:^(BOOL finished) {
        if (finished) {
            if (seekToTimeComplete) seekToTimeComplete();
        }
    }];
}


- (void) play;
{
    PRLog(@"");
    self.isPlaying = true;
    [self.player play];
}

- (void) pause;
{
    PRLog(@"");
    self.isPlaying = false;
    [self.player pause];
}

- (void) releasePlayer;
{
    PRLog(@"");
    isValidToMonitorPlayer = false;
    if (self.player) {
        PRLog(@"stopping player");
        [self pause];
        self.playerItem = nil;
        self.player = nil;
    }
}

- (void) monitorPlayerTime_bg {
    isValidToMonitorPlayer = true;
    while (isValidToMonitorPlayer) {
        if (!self.player) break;
        double playerTime = CMTimeGetSeconds(self.player.currentTime);
        [self performSelectorOnMainThread:@selector(playerTimeUpate:) withObject:[NSNumber numberWithDouble:playerTime] waitUntilDone:NO];
        [NSThread sleepForTimeInterval:PLAYER_MONITOR_PERIOD];
    }
}

- (void) playerTimeUpate:(NSNumber*)nsTime {
    if (self.delegate) [self.delegate playerTimeUpate:nsTime];
}




@end
