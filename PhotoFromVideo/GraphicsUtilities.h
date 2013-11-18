//
//  GraphicsUtilities.h
//  NorbertNipkin
//
//  Created by mike majid on 10-12-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GraphicsUtilities : NSObject {

}

// pubic methods
+ (UIImageView*) getImageViewFromFile:(NSString*)pathToFile x:(int)x y:(int)y;
+ (UIImage*) getImage:(NSString*)pathToFile;
+ (unsigned char*) createSubBlockFromRawData:(unsigned char*)rawData width:(int)width height:(int)height subWidth:(int)subWidth subHeight:(int)subHeight left:(int)left top:(int)top;
+ (BOOL) compareSubBlockWithRawData:(unsigned char*) rawData width:(int)width height:(int)height subData:(unsigned char*)subData subWidth:(int)subWidth subHeight:(int)subHeight x:(int)x y:(int)y;
+ (unsigned char*) createRawDataFromImage:(UIImage*)image;
+ (UIImage*) createImageFromRawData:(unsigned char*)rawData width:(int)width height:(int)height;
+ (BOOL) saveImage:(UIImage*)image toFile:(NSString*)fileName;
+ (UIImage*) cropImage:(NSString*) imageFileName x:(int*)x y:(int*)y;
+ (UIImage*) cropFromImage:(UIImage*) image x:(int*)x y:(int*)y;
+ (CGPoint) extractLocationFromFile:(NSString*)locationFile;

+ (UIImage *)resizeImage:(UIImage*) srcImage
                 newSize:(CGSize)newSize
    interpolationQuality:(CGInterpolationQuality)quality;
+ (UIImage*) rotateImageToOrientationUp:(UIImage*)image;
+ (unsigned char*) getDataBufferFromImage:(UIImage*)image;

@end
