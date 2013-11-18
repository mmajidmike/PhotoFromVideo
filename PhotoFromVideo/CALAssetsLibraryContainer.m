//
//  CALAssetsLibraryContainer.m
//  VideoEdit
//
//  Created by mike majid on 2013-02-06.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CALAssetsLibraryContainer.h"

@implementation CALAssetsLibraryContainer

static ALAssetsLibrary *library = nil;

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    // static dispatch_once_t pred = 0;
    // static ALAssetsLibrary *library = nil;
    // dispatch_once(&pred, ^{
    //     library = [[ALAssetsLibrary alloc] init];
    // });
    
    if (library == nil) library = [[ALAssetsLibrary alloc] init];
    return library;
}

+ (void) releaseALAssetsLibrary {
    library = nil;
}

@end
