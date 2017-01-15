//
//  PushManager.m
//  Time Left
//
//  Created by Salavat Khanov on 1/31/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "PushManager.h"
#import "DataManager.h"

@interface PushManager ()
@property (strong, nonatomic) NSMutableArray *notifications;
@end

@implementation PushManager

// Lazy init
- (NSMutableArray *)notifications {
    if (_notifications == nil) {
        _notifications = [[NSMutableArray alloc] init];
    }
    
    return _notifications;
}
#pragma mark Model Notifications
- (void)registerForModelUpdateNotifications {
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
- (void)eventAdded:(NSNotification *)addedNotification {
    if ([[addedNotification.userInfo allKeys][0] isEqual:kAddedKey]) {
        
        Event *addedEvent = [addedNotification.userInfo objectForKey:kAddedKey];
        UILocalNotification *localNotification = [self createNotificationForEvent:addedEvent];
        if (localNotification) {
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            [self.notifications addObject:localNotification];
        }
    
    }
}
- (void)eventUpdated:(NSNotification *)updatedNotification {
    if ([[updatedNotification.userInfo allKeys][0] isEqual:kUpdatedKey]) {
        Event *updatedEvent = [updatedNotification.userInfo objectForKey:kUpdatedKey];
        
        // Find old notification to cancel
        [self.notifications enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
            if ([updatedEvent.uuid isEqualToString:notification.userInfo[@"eventUUID"]]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                [self.notifications removeObject:notification];
                *stop = YES;
            }
        }];
        
        // Add new notification
        UILocalNotification *newNotification = [self createNotificationForEvent:updatedEvent];
        if (newNotification) {
            [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
            [self.notifications addObject:newNotification];
        }
    }
}
- (void)eventDeleted:(NSNotification *)deletedNotification {
    if ([[deletedNotification.userInfo allKeys][0] isEqual:kDeletedKey]) {
        Event *deletedEvent = [deletedNotification.userInfo objectForKey:kDeletedKey];
        // Find notification to cancel
        [self.notifications enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
            if ([deletedEvent.uuid isEqualToString:notification.userInfo[@"eventUUID"]]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                [self.notifications removeObject:notification];
                *stop = YES;
            }
        }];
    }
}
- (UILocalNotification *)createNotificationForEvent:(Event *)event {
    NSString *notificationTitle = NSLocalizedString(@"is happening today", nil);
    // Create notification only for event that are going to end in the future
    if ([event.endDate compare:[NSDate date]] == NSOrderedDescending) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [self dateByAddingHours:9 date:event.startDate];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ %@.", event.name, notificationTitle];
        localNotification.timeZone = [NSTimeZone systemTimeZone];
        localNotification.alertAction = NSLocalizedString(@"check", nil);
        localNotification.soundName = @"notification-sound.caf";
        localNotification.userInfo = @{@"eventUUID" : event.uuid};
        return localNotification;
    }
    
    return nil;
}

- (NSDate *)dateByAddingHours:(NSInteger)hours date:(NSDate *)date {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:hours];
    
    return [[NSCalendar currentCalendar]
            dateByAddingComponents:components toDate:date options:0];
}

@end
