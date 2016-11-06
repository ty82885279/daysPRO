//
//  AppDelegate.m
//  Time Left
//
//  Created by Salavat Khanov on 7/22/13.
//  Copyright (c) 2013 Salavat Khanov. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager.h"
#import "ThemeManager.h"

@interface AppDelegate() <UIAlertViewDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupAppearance];
    [self setupPushNotificationsManager];
    [self setupDefaultEventsIfNeeded];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setRingRadius:1];
    [SVProgressHUD setHapticsEnabled:true];
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    
    [Fabric with:@[[Answers class]]];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    return YES;
}

- (void)setupAppearance {
    [[[ThemeManager alloc] init] setTheme];
    self.window.tintColor = [[[ThemeManager alloc] init] getTintColor];
    
    // Remove the 1pt underline under the navbar
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}

- (void)setupPushNotificationsManager {
    self.pushManager = [[PushManager alloc] init];
    [self.pushManager registerForModelUpdateNotifications];
}

- (void)setupDefaultEventsIfNeeded {
    // Create Default events if needed
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever. Create some events
        NSLog(@"First launch. Create default events.");
        [[DataManager sharedManager] createDefaultEvents];
        [[DataManager sharedManager] saveContext];
    }
    //Create christmas events if it's december
    if ([[[ThemeManager alloc] init] isDecember]) {
        int currentYear = [[[ThemeManager alloc] init] getCurrentYear];
        NSString *preferenceName = [NSString stringWithFormat:@"addedChristmasEvents%i", currentYear];
#ifdef DEBUG
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:preferenceName];
#endif
        if (![[NSUserDefaults standardUserDefaults] boolForKey:preferenceName]) {
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:preferenceName];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[DataManager sharedManager] addChristmasEvents];
            [[DataManager sharedManager] saveContext];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
