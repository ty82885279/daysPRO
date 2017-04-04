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
#import "EventDetailsViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupPushNotificationsManager];
    [[DataManager sharedManager] addEventsFromServer];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setRingRadius:1];
    [SVProgressHUD setHapticsEnabled:true];
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"defaultThemeSet"]) {
        [self setDefaultTheme];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"defaultThemeSet"];
    }
    
    [self.window setTintColor:[ThemeManager getThemeColor]];
    [Fabric with:@[[Answers class]]];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    return YES;
}
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    NSArray *allEvents = [[DataManager sharedManager] getAllEvents];
    int index = shortcutItem.type.intValue;
    if (index < allEvents.count) {
        Event *tappedEvent = [allEvents objectAtIndex:index];
        
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main-iPhone" bundle: nil];
        EventDetailsViewController *controller = (EventDetailsViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"eventDetails"];
        controller.event = tappedEvent;
        [navigationController pushViewController:controller animated:YES];
        
        [Answers logCustomEventWithName:@"Open event using Force Touch" customAttributes:@{@"Name":tappedEvent.name}];
    }
}
- (void)setDefaultTheme {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"202020" forKey:@"backgroundColor"];
    [defaults setObject:@"FF9500" forKey:@"themeColor"];
    [defaults setObject:@"522A27" forKey:@"circleBackgroundColor"];
    [defaults setBool:true forKey:@"darkMode"];
    
}
- (void)setupPushNotificationsManager {
    self.pushManager = [[PushManager alloc] init];
    [self.pushManager registerForModelUpdateNotifications];
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
