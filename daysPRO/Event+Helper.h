//
//  Event+Helper.h
//  Time Left
//
//  Created by Salavat Khanov on 1/25/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "Event.h"

@interface Event (Helper)

- (UIImage *)image;
- (CGFloat)progress;
- (NSString *)description;
- (BOOL)isOver;
- (NSInteger)daysLeftToDate:(NSDate *)date;
- (NSInteger)hoursLeftToDate:(NSDate *)date;
- (NSInteger)minutesLeftToDate:(NSDate *)date;
- (NSInteger)secondsLeftToDate:(NSDate *)date;

- (NSDictionary *)bestNumberAndText;

@end
