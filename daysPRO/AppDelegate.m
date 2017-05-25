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
#import "Days_Pro-Swift.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupPushNotificationsManager];
    [[DataManager sharedManager] addEventsFromServer];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setRingRadius:1];
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"defaultThemeSet"]) {
        [self setDefaultTheme];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"defaultThemeSet"];
    }
    
    [self.window setTintColor:[ThemeManager getThemeColor]];
    [Fabric with:@[[Answers class]]];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          UIUserNotificationTypeAlert|
          UIUserNotificationTypeBadge|
          UIUserNotificationTypeSound categories:nil]];
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
        EventViewController *controller = (EventViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"eventDetails"];
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

#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
