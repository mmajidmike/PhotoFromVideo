//
//  AppDelegate.m
//  PhotoFromVideo
//
//  Created by mike majid on 2013-11-07.
//  Copyright (c) 2013 mike majid. All rights reserved.
//

#import "AppDelegate.h"
#import "ShareKit.h"
#import "SHKDropbox.h"
#import "SHKGooglePlus.h"
#import "SHKFacebook.h"
#import "EvernoteSDK.h"
#import "SHKBuffer.h"
#import "PocketAPI.h"
#import "SHKConfiguration.h"
#import "MySHKConfigurator.h"

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


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    return [SHKFacebook handleOpenURL:url];
    
    /*****
     if ([scheme hasPrefix:[NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)]]) {
     return [SHKFacebook handleOpenURL:url];
     }
     else if ([scheme isEqualToString:@"com.yourcompany.sharekitdemo"]) {
     return [SHKGooglePlus handleURL:url sourceApplication:sourceApplication annotation:annotation];
     } else if ([scheme hasPrefix:[NSString stringWithFormat:@"db-%@", SHKCONFIG(dropboxAppKey)]]) {
     return [SHKDropbox handleOpenURL:url];
     } else if ([[NSString stringWithFormat:@"en-%@", [[EvernoteSession sharedSession] consumerKey]] isEqualToString:[url scheme]]) {
     return [[EvernoteSession sharedSession] canHandleOpenURL:url];
     } else if ([scheme hasPrefix:[NSString stringWithFormat:@"buffer%@", SHKCONFIG(bufferClientID)]]) {
     return [SHKBuffer handleOpenURL:url];
     } else if ([scheme hasPrefix:[NSString stringWithFormat:@"pocketapp%@", pocketPrefixKeyPart]]) {
     return [[PocketAPI sharedAPI] handleOpenURL:url];
     }
     
     return YES;
     // ***/
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    DefaultSHKConfigurator *configurator = [[MySHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [SHKFacebook handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{    
    [SHKFacebook handleWillTerminate];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) return UIInterfaceOrientationMaskAll;
    else return UIInterfaceOrientationMaskPortrait;
}

#pragma mark-facebook

@end
