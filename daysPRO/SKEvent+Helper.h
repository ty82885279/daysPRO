//
//  SKEvent+Helper.h
//  Time Left
//
//  Created by Salavat Khanov on 1/25/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "SKEvent.h"

@protocol SKEventMethods <NSObject>

@required
- (CGFloat)progress;
- (NSInteger)daysLeftToDate:(NSDate *)date;
- (NSInteger)hoursLeftToDate:(NSDate *)date;
- (NSInteger)minutesLeftToDate:(NSDate *)date;
- (NSInteger)secondsLeftToDate:(NSDate *)date;
- (NSDictionary *)bestNumberAndText;
@end


@interface SKEvent (Helper) <SKEventMethods>

- (CGFloat)progress;
- (NSString *)description;

- (NSInteger)daysLeftToDate:(NSDate *)date;
- (NSInteger)hoursLeftToDate:(NSDate *)date;
- (NSInteger)minutesLeftToDate:(NSDate *)date;
- (NSInteger)secondsLeftToDate:(NSDate *)date;

- (NSDictionary *)bestNumberAndText;

@end
