//
//  SKDataManager.h
//  Time Left
//
//  Created by Salavat Khanov on 1/25/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKEvent.h"
#import "SKEvent+Helper.h"

extern NSString *const kEventAddedNotificationName;
extern NSString *const kEventUpdatedNotificationName;
extern NSString *const kEventDeletedNotificationName;

extern NSString *const kAddedKey;
extern NSString *const kUpdatedKey;
extern NSString *const kDeletedKey;

@interface SKDataManager : NSObject

+ (SKDataManager *)sharedManager;
- (void)saveContext;

// Bulk Add/Delete
- (void)createDefaultEvents;
- (void)deleteAllEvents;

// Events
- (NSArray *)getAllEvents;
- (SKEvent *)createEventWithName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate details:(NSString *)details;
- (SKEvent *)updateEvent:(SKEvent *)event withName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate details:(NSString *)details;
- (void)deleteEvent:(SKEvent *)event;

// Notifications
- (void)objectContextDidSave:(NSNotification *)notification;

@end
