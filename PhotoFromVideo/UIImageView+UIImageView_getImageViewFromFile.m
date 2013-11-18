//
//  UIImageView+UIImageView_getImageViewFromFile.m
//  PhotoFromVideo
//
//  Created by mike majid on 2013-11-18.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "UIImageView+UIImageView_getImageViewFromFile.h"

@implementation UIImageView (UIImageView_getImageViewFromFile)

+ (UIImageView*) GetImageViewFromFile:(NSString*) fileName;
{
    NSBundle *bundle = [NSBundle mainBundle];
	NSString *pathToResource = [bundle bundlePath];
	NSString* pathToImage = [NSString stringWithFormat:@"%@/%@",pathToResource, fileName];
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:pathToImage]; // [[[UIImage alloc] initWithContentsOfFile:pathToImage] retain];
	CGRect imageFrame = CGRectMake(0,0, image.size.width, image.size.height);
	UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = imageFrame;
	
	// run-and-analyze complains of leak ... maybe of image ?
	return imageView;
}

@end
