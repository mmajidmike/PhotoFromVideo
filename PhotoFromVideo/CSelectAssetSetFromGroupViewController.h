//
//  CSelectAssetSetFromGroupViewController.h
//  VideoEdit
//
//  Created by mike majid on 2013-01-02.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CAssetImageView.h"

@interface CSelectAssetSetFromGroupViewController : UITableViewController <CAssetImageViewDelegate, UIPopoverControllerDelegate>
{
    NSMutableArray* ALAssetArray;
    NSMutableArray* selectedAssetIndexArray;
    NSMutableArray* assetImageViewArray;
    int numImagesPerRowLandscape;
    int numImagesPerRowPortrait;
    BOOL alreadyScrolledToBottomOfTableView;
}

@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic, copy) void(^videoElementsSelectedCallBack)(NSArray* assetArray, NSArray* videoElementArray);
@property (nonatomic, copy) void(^assetSelectedCallBack)(ALAsset* alasset);
@property (nonatomic, assign, setter = set_assetGroup:) ALAssetsGroup* assetGroup;

@end
