//
//  CServer.m
//  VideoEdit
//
//  Created by mike majid on 2013-10-02.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "CServer.h"

#import "GlobalDebug.h"
#ifdef GLOBAL_DEBUG
#define LOCAL_DEBUG
#ifdef LOCAL_DEBUG
#define PRLog(...) NSLog(@"%s:%d %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define PRLog(...) do { } while (0)
#endif
#else
#define PRLog(...) do { } while (0)
#endif


@implementation CServer

+ (NSString*) getCompletPathToWebPage;
{
    NSString* completPathToWebPage = [NSString stringWithFormat:@"%@%@", SERVER_ADDRESS, EZ_VID_EDIT_WEB_PAGE];
    return completPathToWebPage;
}
+ (NSString*) getAppName;
{
    return APP_NAME;
}

- (id) init;
{
    PRLog(@"");
    self = [super init];
    if (self) {
    }
    return self;
}
- (void) dealloc;
{
    PRLog(@"");
}

@end
