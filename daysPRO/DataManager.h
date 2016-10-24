//
//  DataManager.h
//  Time Left
//
//  Created by Salavat Khanov on 1/25/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Event+Helper.h"

extern NSString *const kEventAddedNotificationName;
extern NSString *const kEventUpdatedNotificationName;
extern NSString *const kEventDeletedNotificationName;

extern NSString *const kAddedKey;
extern NSString *const kUpdatedKey;
extern NSString *const kDeletedKey;

@interface DataManager : NSObject

+ (DataManager *)sharedManager;
- (void)saveContext;

// Bulk Add/Delete
- (void)createDefaultEvents;
- (void)deleteAllEvents;

// Events
- (NSArray *)getAllEvents;
- (Event *)createEventWithName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate details:(NSString *)details;
- (Event *)updateEvent:(Event *)event withName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate details:(NSString *)details;
- (void)deleteEvent:(Event *)event;

// Notifications
- (void)objectContextDidSave:(NSNotification *)notification;

@end