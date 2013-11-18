//
//  GraphicsUtilities.m
//  NorbertNipkin
//
//  Created by mike majid on 10-12-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GraphicsUtilities.h"

#import "GlobalDebug.h"
#ifdef GLOBAL_DEBUG
// #define LOCAL_DEBUG
#ifdef LOCAL_DEBUG
#define PRLog(...) NSLog(@"%s:%d %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define PRLog(...) do { } while (0)
#endif
#else
#define PRLog(...) do { } while (0)
#endif


@implementation GraphicsUtilities

/**
 *
 * create a UIImabeView instance from the specified image file
 * update teh imageView frame to the location specified
 *
 **/
+ (UIImageView*) getImageViewFromFile:(NSString*)pathToFile x:(int)x y:(int)y {
	NSBundle *bundle = [NSBundle mainBundle]; 
	NSString *pathToResource = [bundle bundlePath];
	NSString* pathToImage = [NSString stringWithFormat:@"%@/%@",pathToResource, pathToFile];
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:pathToImage]; // [[[UIImage alloc] initWithContentsOfFile:pathToImage] retain];
	CGRect imageFrame = CGRectMake(x, y, image.size.width, image.size.height);
	UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = imageFrame;
	// [image release];
	
	// release stuff before returning
	// [pathToImage release];
	// [image release];
	
	// run-and-analyze complains of leak ... maybe of image ?
	return imageView;
}

/**
 *
 * create a UIImabeView instance from the specified image file
 * update teh imageView frame to the location specified
 *
 **/
+ (UIImage*) getImage:(NSString*)pathToFile {
	NSBundle *bundle = [NSBundle mainBundle]; 
	NSString *pathToResource = [bundle bundlePath];
	NSString* pathToImage = [NSString stringWithFormat:@"%@/%@",pathToResource, pathToFile];
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:pathToImage];
	// CGRect imageFrame = CGRectMake(x, y, image.size.width, image.size.height);
	// UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
	// imageView.frame = imageFrame;
	// [image release];
	
	// run-and-analyze complains of leak
	return image;
}

+ (unsigned char*) createSubBlockFromRawData:(unsigned char*)rawData width:(int)width height:(int)height subWidth:(int)subWidth subHeight:(int)subHeight left:(int)left top:(int)top {
	PRLog(@"createSubBlockFromRawData() wh=(%d,%d) sub wh=(%d,%d) lt=(%d,%d)", width, height, subWidth, subHeight, left, top);
	int bytesPerPixel = 4;
	int numBytes = subWidth * subHeight * bytesPerPixel;
	unsigned char *rawDataSubBlock = malloc(numBytes);
	for (int i=0 ; i<numBytes ; i++) rawDataSubBlock[i] = 0x0; // 0xff;
	int right = left + subWidth;
	int bottom = top + subHeight;
	int dstAddress = 0;
	for (int y=top ; y<bottom ; y++) {
		for (int x=left ; x<right ; x++) {
			int srcAddress = (y*width + x)*bytesPerPixel;
			unsigned char red        = rawData[srcAddress + 0];
			unsigned char green      = rawData[srcAddress + 1];
			unsigned char blue       = rawData[srcAddress + 2];
			unsigned char alphaValue = rawData[srcAddress + 3];
			double falp = (double)alphaValue/255.0;
			rawDataSubBlock[dstAddress + 0] = (unsigned char)(red*falp) & 0xff; // rawData[srcAddress + 0]; 
			rawDataSubBlock[dstAddress + 1] = (unsigned char)(green*falp) & 0xff; // rawData[srcAddress + 1]; 
			rawDataSubBlock[dstAddress + 2] = (unsigned char)(blue*falp) & 0xff; // rawData[srcAddress + 2]; 
			rawDataSubBlock[dstAddress + 3] = (unsigned char)(alphaValue) & 0xff; // rawData[srcAddress + 3]; 
			PRLog(@"createSubBlockFromRawData() xy=(%d,%d) alp=%d", x,y, alphaValue);
			dstAddress += 4;
		}
	}
	// BOOL compare = [self compareSubBlockWithRawData:rawData width:width height:height subData:rawDataSubBlock subWidth:subWidth subHeight:subHeight x:left y:top];
	// PRLog(@"createSubBlockFromRawData() compare=%d", compare);
	return rawDataSubBlock;
}

+ (BOOL) compareSubBlockWithRawData:(unsigned char*) rawData width:(int)width height:(int)height subData:(unsigned char*)subData subWidth:(int)subWidth subHeight:(int)subHeight x:(int)x y:(int)y {
	int bytesPerPixel = 4;
	int left = x;
	int right = x + subWidth;
	int top = y;
	int bottom = y + subHeight;
	int dstAddress = 0;
	int numMatches = 0;
	int numMisMatches = 0;
	for (int y=top ; y<bottom ; y++) {
		for (int x=left ; x<right ; x++) {
			int srcAddress = (y*width + x)*bytesPerPixel;
			unsigned char srcRed = rawData[srcAddress + 0] & 0xff; 
			unsigned char srcGrn = rawData[srcAddress + 1] & 0xff;
			unsigned char srcBlu = rawData[srcAddress + 2] & 0xff;
			unsigned char srcAlp = rawData[srcAddress + 3] & 0xff; 
			unsigned char dstRed = subData[dstAddress + 0] & 0xff; 
			unsigned char dstGrn = subData[dstAddress + 1] & 0xff;
			unsigned char dstBlu = subData[dstAddress + 2] & 0xff;
			unsigned char dstAlp = subData[dstAddress + 3] & 0xff; 			
			if (srcRed != dstRed) {
				PRLog(@"compareSubBlockWithRawData() red mismatch %d != %d", srcRed, dstRed);
				numMisMatches++; 
			}
			else numMatches++;
			if (srcGrn != dstGrn) {
				numMisMatches++; 
			}
			else numMatches++;
			if (srcBlu != dstBlu) {
				numMisMatches++; 
			}
			else numMatches++;
			if (srcAlp != dstAlp) {
				PRLog(@"compareSubBlockWithRawData() alp mismatch %d != %d", srcAlp, dstAlp);
				numMisMatches++; 
			}
			else numMatches++;
			dstAddress += 4;
		}
	}
	
	PRLog(@"compareSubBlockWithRawData() numMatches=%d numMisMatches=%d", numMatches, numMisMatches);
	if (numMisMatches == 0)return true;
	else return false;
}

+ (unsigned char*) createRawDataFromImage:(UIImage*)image
{
    // NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
	
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,bitsPerComponent, bytesPerRow, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	// CGContextRef context = CGBitmapContextCreate(rawData, width, height,bitsPerComponent, bytesPerRow, colorSpace, kCGBitmapByteOrder32Big);
	// CGContextRef context = CGBitmapContextCreate(rawData, width, height,bitsPerComponent, bytesPerRow, colorSpace,kCGImageAlphaPremultipliedLast);
	// CGContextRef context = CGBitmapContextCreate(rawData, width, height,bitsPerComponent, bytesPerRow, colorSpace,kCGImageAlphaLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
	
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
	
	/******
	 // Now your rawData contains the image data in the RGBA8888 pixel format.
	 int byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
	 for (int ii = 0 ; ii < count ; ++ii)
	 {
	 CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
	 CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
	 CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
	 CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
	 byteIndex += 4;
	 
	 UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
	 [result addObject:acolor];
	 }
	 
	 // free(rawData);
	 // ****/
	
	return rawData;
}

+ (UIImage*) createImageFromRawData:(unsigned char*)rawData width:(int)width height:(int)height {
	NSInteger myDataLength = width * height * 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, rawData, myDataLength, NULL);
	
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    // CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
	// CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaLast;
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
	
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	// release stuff
	// not sure of this release
	CGDataProviderRelease(provider); // [provider release];
	CGColorSpaceRelease(colorSpaceRef);
	
    return myImage;	
}

+ (BOOL) saveImage:(UIImage*)image toFile:(NSString*)fileName {
	// PRLog(@"GraphicsUtilities.saveImage() fileName=%@", fileName);
	
	// get the documents directory
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	// int numPaths = [paths count];
	NSString* pathToDocuments = [paths objectAtIndex:0];
	NSString* screenShotDirectory = [NSString stringWithFormat:@"%@/screenShots", pathToDocuments];
	// PRLog(@"GraphicsUtilities.saveImage() pathToDocuments=%@", pathToDocuments);
	// PRLog(@"GraphicsUtilities.saveImage() screenShotDirectory=%@", screenShotDirectory);
	
	// check if the screenShots directory exists
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL screenShotDirExists = [fileManager fileExistsAtPath:screenShotDirectory];
	// PRLog(@"GraphicsUtilities.saveImage() screenShotDirExists=%d", screenShotDirExists);
	
	// if screenShot directory does not exist, create it
	if (screenShotDirExists == false) {
		NSError* error;
		BOOL pathCreated = [fileManager createDirectoryAtPath:screenShotDirectory withIntermediateDirectories:YES attributes:nil error:&error];
		// PRLog(@"GraphicsUtilities.saveImage() pathCreated=%d", pathCreated);
		if (pathCreated == false) return false;
	}
	
	// save the screenshot
	NSString* imagePath = [NSString stringWithFormat:@"%@/%@", screenShotDirectory, fileName];
	// PRLog(@"GraphicsUtilities.saveImage() imagePath=%@", imagePath);
	NSData* imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
	BOOL fileWritten = [imageData writeToFile:imagePath atomically:YES];
	// PRLog(@"GraphicsUtilities.saveImage() fileWritten=%d", fileWritten);
	
	return fileWritten;
}

+ (UIImage*) cropImage:(NSString*) imageFileName x:(int*)x y:(int*)y{
	UIImage* image = [GraphicsUtilities getImage:imageFileName];
	int width = image.size.width;
	int height = image.size.height;
	int left = width;
	int right = 0;
	int top = height;
	int bottom = 0;
	// PRLog(@"cropImage() imageFileName=%@ wh=(%d,%d)", imageFileName, width, height);
	unsigned char* rawData = [GraphicsUtilities createRawDataFromImage:image];
	for (int row=0 ; row<height ; row++) {
		for (int col=0 ; col<width ; col++) {
			int pixelIndex = ((row*width) + col)*4;
			// unsigned char red        = rawData[pixelIndex + 0];
			// unsigned char green      = rawData[pixelIndex + 1];
			// unsigned char blue       = rawData[pixelIndex + 2];
			unsigned char alphaValue = rawData[pixelIndex + 3];
			// PRLog(@"   rc=(%d,%d) rgba=(%x,%x,%x,%x)", row, col, red,green,blue,alphaValue);
			if (alphaValue != 0) {
				if (col < left) left = col;
				if (col > right) right = col;
				if (row < top) top = row;
				if (row > bottom) bottom = row;
			}
		}
	}
	
	// left-= 16;
	// right+= 16;
	// top-= 16;
	// bottom+= 16;
	int croppedWidth = right-left+1;
	int croppedHeight = bottom - top+1;
	PRLog(@"cropImage wh=(%d,%d) lr=(%d,%d) tb=(%d,%d) wh=(%d,%d)", width, height, left, right, top, bottom, croppedWidth, croppedHeight);
		
	// try and crop an image
	CGImageRef tmp = CGImageCreateWithImageInRect([image CGImage], CGRectMake(left, top, croppedWidth, croppedHeight));
	// [tileImgArray addObject:[UIImage imageWithCGImage:tmp]];
	// UIImageView* newImage = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:tmp]];
	UIImage* croppedImage = [UIImage imageWithCGImage:tmp];
	*x = left;
	*y = top;
	
	
	free(rawData);
	
	// not sure of this release
	CGImageRelease(tmp);
	return croppedImage;
}

+ (UIImage*) cropFromImage:(UIImage*) image x:(int*)x y:(int*)y{
	int width = image.size.width;
	int height = image.size.height;
	int left = width;
	int right = 0;
	int top = height;
	int bottom = 0;
	// PRLog(@"cropImage() imageFileName=%@ wh=(%d,%d)", imageFileName, width, height);
	unsigned char* rawData = [GraphicsUtilities createRawDataFromImage:image];
	for (int row=0 ; row<height ; row++) {
		for (int col=0 ; col<width ; col++) {
			int pixelIndex = ((row*width) + col)*4;
			// unsigned char red        = rawData[pixelIndex + 0];
			// unsigned char green      = rawData[pixelIndex + 1];
			// unsigned char blue       = rawData[pixelIndex + 2];
			unsigned char alphaValue = rawData[pixelIndex + 3];
			// PRLog(@"   rc=(%d,%d) rgba=(%x,%x,%x,%x)", row, col, red,green,blue,alphaValue);
			if (alphaValue != 0) {
				if (col < left) left = col;
				if (col > right) right = col;
				if (row < top) top = row;
				if (row > bottom) bottom = row;
			}
		}
	}
	
	// left-= 16;
	// right+= 16;
	// top-= 16;
	// bottom+= 16;
	int croppedWidth = right-left+1;
	int croppedHeight = bottom - top+1;
	// PRLog(@"cropImage wh=(%d,%d) lr=(%d,%d) tb=(%d,%d) wh=(%d,%d)", width, height, left, right, top, bottom, croppedWidth, croppedHeight);
		
	// try and crop an image
	CGImageRef tmp = CGImageCreateWithImageInRect([image CGImage], CGRectMake(left, top, croppedWidth, croppedHeight));
	// [tileImgArray addObject:[UIImage imageWithCGImage:tmp]];
	// UIImageView* newImage = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:tmp]];
	UIImage* croppedImage = [UIImage imageWithCGImage:tmp];
	*x = left;
	*y = top;
	
	
	free(rawData);
	CGImageRelease(tmp);
	return croppedImage;
}


+ (CGPoint) extractLocationFromFile:(NSString*)locationFile {
	NSBundle *bundle = [NSBundle mainBundle]; 
	NSString *pathToResource = [bundle bundlePath];
	NSString* pathToFile = [NSString stringWithFormat:@"%@/%@",pathToResource, locationFile];		
	NSString *fileContents = [NSString stringWithContentsOfFile:pathToFile encoding:NSASCIIStringEncoding error:nil];
	// PRLog(@"CImageAtPoint.extractLocationFromFile(%@) %@", locationFile, fileContents);
	NSArray* tokenArray = [fileContents componentsSeparatedByString:@" "];
	// int tokenArrayCount = [tokenArray count];
	// PRLog(@"CImageAtPoint.extractLocationFromFile() tokenArrayCount=%d", tokenArrayCount);	
	CGPoint imageLocation;
	imageLocation.x = [[tokenArray objectAtIndex:0] intValue];
	imageLocation.y = [[tokenArray objectAtIndex:1] intValue];
	return imageLocation;
}

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
+ (UIImage *)resizeImage:(UIImage*) srcImage
                 newSize:(CGSize)newSize
                // transform:(CGAffineTransform)transform
           // drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    // CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = srcImage.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef)); // kCGImageAlphaNoneSkipLast); // CGImageGetBitmapInfo(imageRef));
    
    // // Rotate and/or flip the image if required by its orientation
    // CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    // CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    CGContextDrawImage(bitmap, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

+ (UIImage*) rotateImageToOrientationUp:(UIImage*)srcImage {
    PRLog(@"");
    
    CGInterpolationQuality quality = kCGInterpolationHigh;
    CGSize newSize = srcImage.size;
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2.0);
    CGImageRef imageRef = srcImage.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef)); // kCGImageAlphaNoneSkipLast); // CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    BOOL transpose = true;
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    // CGContextDrawImage(bitmap, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;    
}


+ (unsigned char*) getDataBufferFromImage:(UIImage*)image {
    // UIColor* color = nil;
	CGImageRef inImage = image.CGImage; // self.image.CGImage;
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    
	// CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    
    
    CGContextRef    cgctx = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
    
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	cgctx = CGBitmapContextCreate (bitmapData,
                                   pixelsWide,
                                   pixelsHigh,
                                   8,      // bits per component
                                   bitmapBytesPerRow,
                                   colorSpace,
                                   (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
	if (cgctx == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
    
    
	if (cgctx == NULL) { return nil; /* error */ }
	
    size_t w = CGImageGetWidth(inImage);
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{w,h}};
	
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, inImage);
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	unsigned char* dataBuffer = CGBitmapContextGetData (cgctx);
    unsigned char* data = malloc( bitmapByteCount ); // dataBuffer;
    memcpy(data, dataBuffer, bitmapByteCount);
    
    CGContextRelease(cgctx);
	// Free image data memory for the context
	// if (data) { free(data); }
    if (bitmapData) free(bitmapData);
    
    return data;
}




@end
