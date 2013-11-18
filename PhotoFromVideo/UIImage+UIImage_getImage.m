//
//  UIImage+UIImage_getImage.m
//  PhotoFromVideo
//
//  Created by mike majid on 2013-11-18.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "UIImage+UIImage_getImage.h"

@implementation UIImage (UIImage_getImage)

+ (UIImage*) GetImageFromFile:(NSString*) fileName;
{
    NSBundle *bundle = [NSBundle mainBundle];
	NSString *pathToResource = [bundle bundlePath];
	NSString* pathToImage = [NSString stringWithFormat:@"%@/%@",pathToResource, fileName];
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:pathToImage];
	
	// run-and-analyze complains of leak
	return image;
}

@end
