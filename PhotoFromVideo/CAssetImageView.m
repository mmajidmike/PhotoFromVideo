//
//  CAssetImageView.m
//  VideoEdit
//
//  Created by mike majid on 2013-01-03.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CAssetImageView.h"
#import "UIImageView+UIImageView_getImageViewFromFile.h"

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

@implementation CAssetImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        assetSelectedOverlayImageView = [UIImageView GetImageViewFromFile:@"AssetSelectedOverlay.png"];
        assetSelectedOverlayImageView.userInteractionEnabled = false;
        
        int x = 0;
        int y = 0.8 * frame.size.height;
        int width = frame.size.width;
        int height = 0.2 * frame.size.height;
        CGRect videoDurationPanelFrame = CGRectMake(x, y, width, height);
        videoDurationPanelView = [[UIView alloc] initWithFrame:videoDurationPanelFrame];
        CGFloat red = 0;
        CGFloat grn = 0;
        CGFloat blu = 0;
        CGFloat alp = 0.3;
        videoDurationPanelView.backgroundColor = [UIColor colorWithRed:red green:grn blue:blu alpha:alp];
        
        UIFont* font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
        CGRect videoDurationLabelFrame = videoDurationPanelFrame;
        videoDurationLabelFrame.origin.y = 2;
        videoDurationLabel = [[UILabel alloc] initWithFrame:videoDurationLabelFrame];
        videoDurationLabel.font = font;
        videoDurationLabel.backgroundColor = [UIColor clearColor];
        videoDurationLabel.textColor = [UIColor whiteColor];
        videoDurationLabel.textAlignment = NSTextAlignmentRight;
        // videoDurationLabel.text = @"5:02";
        [videoDurationPanelView addSubview:videoDurationLabel];
        
        int cameraIconHeight = height * 0.6;
        int cameraIconWidth = 2 * cameraIconHeight;
        int cx = 4;
        int cy = 4;
        CGRect cameraIconImageViewFrame = CGRectMake(cx, cy, cameraIconWidth, cameraIconHeight);
        UIImageView* cameraIconImageView = [UIImageView GetImageViewFromFile:@"CameraIcon.png"];
        cameraIconImageView.frame = cameraIconImageViewFrame;
        [videoDurationPanelView addSubview:cameraIconImageView];
        
        
        [self addSubview:videoDurationPanelView];
        [self addSubview:assetSelectedOverlayImageView];
        
        [self setSelected:false];
        videoDurationPanelView.alpha = 0;
    }
    return self;
}

- (void) dealloc {
    // PRLog(@"");
}

- (void) setVideoDuration:(NSString*) videoDurationText {
    if (videoDurationText == nil) {
        videoDurationPanelView.alpha = 0;
    }
    else {
        videoDurationPanelView.alpha = 1.0;
        videoDurationLabel.text = videoDurationText;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // PRLog(@"index=%d", _assetIndex);
    // self.alpha = 0.2;
    // [self setSelected:false];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // PRLog(@"index=%d", _assetIndex);
    // self.alpha = 1.0;
    // [self setSelected:true];
    
    [_delegate assetImageViewTapped:self];
}

- (void) setSelected:(BOOL) selected {
    // PRLog(@"assetIndex=%d selected=%d", _assetIndex, selected);
    if (selected) assetSelectedOverlayImageView.alpha = 1.0; // self.alpha = 0.2;
    else assetSelectedOverlayImageView.alpha = 0;; // self.alpha = 1.0;
    // [self setSelected:true];
}

- (BOOL) isSelected;
{
    if (assetSelectedOverlayImageView.alpha == 0) return false;
    else return true;
}

@end
