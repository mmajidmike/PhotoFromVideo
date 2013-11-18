//
//  CSelectNewVideoElementSetViewController.h
//  VideoEdit
//
//  Created by mike majid on 2013-01-01.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CSelectNewVideoElementSetViewController : UITableViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic, retain) NSMutableArray* assetGroupArray;
@property (nonatomic, copy) void(^videoElementsSelectedCallBack)(NSArray* assetArray, NSArray* videlElementArray);
@property (nonatomic, copy) void(^assetSelectedCallBack)(ALAsset* alasset);

+ (NSMutableArray*) ExtractAssetGroupArray;

@end
