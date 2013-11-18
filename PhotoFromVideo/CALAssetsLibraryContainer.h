//
//  CALAssetsLibraryContainer.h
//  VideoEdit
//
//  Created by mike majid on 2013-02-06.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CALAssetsLibraryContainer : NSObject

+ (ALAssetsLibrary *)defaultAssetsLibrary;
+ (void) releaseALAssetsLibrary;

@end
