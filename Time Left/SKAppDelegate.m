//
//  SKAppDelegate.m
//  Time Left
//
//  Created by Salavat Khanov on 7/22/13.
//  Copyright (c) 2013 Salavat Khanov. All rights reserved.
//

#import "SKAppDelegate.h"
#import "SKDataManager.h"

@interface SKAppDelegate() <UIAlertViewDelegate>
@end

@implementation SKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAppearance];
    [self setupPushNotificationsManager];
    [self setupDefaultEventsIfNeeded];
    
    return YES;
}

- (void)setupAppearance
{
    self.window.tintColor = [UIColor whiteColor];
    
    // Remove the 1pt underline under the navbar
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}

- (void)setupPushNotificationsManager
{
    self.pushManager = [[SKPushManager alloc] init];
    [self.pushManager registerForModelUpdateNotifications];
}

- (void)setupDefaultEventsIfNeeded
{
    // Create Default events if needed
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever. Create some events
        NSLog(@"First launch. Create default events.");
        [[SKDataManager sharedManager] createDefaultEvents];
        [[SKDataManager sharedManager] saveContext];
    }
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Theme

- (NSDictionary *)currentTheme
{
    NSDictionary *colors;
    
    colors = @{@"background"            : [UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1.0],
               @"tint"                  : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
               @"colorText"             : [UIColor colorWithRed:254.0/255.0 green:185.0/255.0 blue:52.0/255.0 alpha:1.0],
               @"outerCircleProgress"   : [UIColor colorWithRed:241.0/255.0 green:176.0/255.0 blue:51.0/255.0 alpha:1.0],
               @"outerCircleBackground" : [UIColor colorWithRed:82.0/255.0 green:82.0/255.0 blue:82.0/255.0 alpha:1.0],
               @"innerCircleProgress"   : [UIColor colorWithRed:234.0/255.0 green:129.0/255.0 blue:37.0/255.0 alpha:1.0],
               @"innerCircleBackground" : [UIColor colorWithRed:82.0/255.0 green:82.0/255.0 blue:82.0/255.0 alpha:1.0],
               @"cellBackground"        : [UIColor colorWithRed:92.0/255.0 green:92.0/255.0 blue:92.0/255.0 alpha:1.0]};
    
    return colors;
}

@end
