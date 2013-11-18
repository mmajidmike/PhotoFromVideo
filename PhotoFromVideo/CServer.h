//
//  CServer.h
//  VideoEdit
//
//  Created by mike majid on 2013-10-02.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import <Foundation/Foundation.h>

// replace with path to yor own site and page
#define SERVER_ADDRESS @"http://PhotoFromVideo/"
#define EZ_VID_EDIT_WEB_PAGE @"PhotoFromVideo.html"
#define APP_NAME @"Photo From Video"

@interface CServer : NSObject

+ (NSString*) getCompletPathToWebPage;
+ (NSString*) getAppName;

@end
