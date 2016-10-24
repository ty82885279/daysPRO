//
//  SKPushManager.m
//  Time Left
//
//  Created by Salavat Khanov on 1/31/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "SKPushManager.h"
#import "SKDataManager.h"

@interface SKPushManager ()
@property (strong, nonatomic) NSMutableArray *notifications;
@end

@implementation SKPushManager

// Lazy init
- (NSMutableArray *)notifications
{
    if (_notifications == nil) {
        _notifications = [[NSMutableArray alloc] init];
    }
    
    return _notifications;
}

#pragma mark Model Notifications

- (void)registerForModelUpdateNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventAdded:)
                                                 name:kEventAddedNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventUpdated:)
                                                 name:kEventUpdatedNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventDeleted:)
                                                 name:kEventDeletedNotificationName
                                               object:nil];
}

- (void)eventAdded:(NSNotification *)addedNotification
{
    if ([[addedNotification.userInfo allKeys][0] isEqual:kAddedKey]) {
        
        SKEvent *addedEvent = [addedNotification.userInfo objectForKey:kAddedKey];
        UILocalNotification *localNotification = [self createNotificationForEvent:addedEvent];
        if (localNotification) {
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            [self.notifications addObject:localNotification];
            NSLog(@"Scheduled notification for %@ at %@ (now = %@)", addedEvent.name, localNotification.fireDate, [NSDate date]);
        }
    
    }
}

- (void)eventUpdated:(NSNotification *)updatedNotification
{
    if ([[updatedNotification.userInfo allKeys][0] isEqual:kUpdatedKey]) {
        SKEvent *updatedEvent = [updatedNotification.userInfo objectForKey:kUpdatedKey];
        
        // Find old notification to cancel
        [self.notifications enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
            if ([updatedEvent.uuid isEqualToString:notification.userInfo[@"eventUUID"]]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                [self.notifications removeObject:notification];
                *stop = YES;
                
                NSLog(@"Cancelled notification for %@ at %@ (now = %@)", updatedEvent.name, notification.fireDate, [NSDate date]);
            }
        }];
        
        // Add new notification
        UILocalNotification *newNotification = [self createNotificationForEvent:updatedEvent];
        if (newNotification) {
            [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
            [self.notifications addObject:newNotification];
            NSLog(@"Updated notification for %@ at %@ (now = %@)", updatedEvent.name, newNotification.fireDate, [NSDate date]);
        }
    }
}

- (void)eventDeleted:(NSNotification *)deletedNotification
{
    if ([[deletedNotification.userInfo allKeys][0] isEqual:kDeletedKey]) {
        SKEvent *deletedEvent = [deletedNotification.userInfo objectForKey:kDeletedKey];
        // Find notification to cancel
        [self.notifications enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
            if ([deletedEvent.uuid isEqualToString:notification.userInfo[@"eventUUID"]]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                [self.notifications removeObject:notification];
                *stop = YES;
                
                NSLog(@"Cancelled notification for %@ at %@ (now = %@)", deletedEvent.name, notification.fireDate, [NSDate date]);
            }
        }];
    }
}

- (UILocalNotification *)createNotificationForEvent:(SKEvent *)event
{
    // Create notification only for event that are going to end in the future
    if ([event.endDate compare:[NSDate date]] == NSOrderedDescending) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = event.endDate;
        localNotification.alertBody = [NSString stringWithFormat:@"%@ is happening now.", event.name];
        localNotification.timeZone = [NSTimeZone systemTimeZone];
        localNotification.alertAction = NSLocalizedString(@"check", @"On lock screen under notification — 'slide to ...' ");
        localNotification.soundName = @"notification-sound.caf";
        localNotification.userInfo = @{@"eventUUID" : event.uuid};
        return localNotification;
    }
    
    return nil;
}

@end
