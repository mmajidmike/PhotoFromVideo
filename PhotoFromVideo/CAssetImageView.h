//
//  CAssetImageView.h
//  VideoEdit
//
//  Created by mike majid on 2013-01-03.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CAssetImageViewDelegate <NSObject>
- (void) assetImageViewTapped:(id) sender;
@end

@interface CAssetImageView : UIImageView
{
    UIImageView* assetSelectedOverlayImageView;
    UIView* videoDurationPanelView;
    UILabel* videoDurationLabel;
}

@property (nonatomic) int assetIndex;
@property (nonatomic, assign) id <CAssetImageViewDelegate> delegate;

- (void) setSelected:(BOOL) selected;
- (BOOL) isSelected;
- (void) setVideoDuration:(NSString*) videoDurationText;

@end
