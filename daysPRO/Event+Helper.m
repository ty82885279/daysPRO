//
//  Event+Helper.m
//  Time Left
//
//  Created by Salavat Khanov on 1/25/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "Event+Helper.h"

static NSString *kWeeksSince = @"WKS SINCE";
static NSString *kDaysSince = @"DAYS SINCE";
static NSString *kHoursSince = @"HRS SINCE";
static NSString *kMinutesSince = @"MINS SINCE";
static NSString *kSecondsSince = @"SECS SINCE";

static NSString *kWeeksLeft = @"WKS LEFT";
static NSString *kDaysLeft = @"DAYS LEFT";
static NSString *kHoursLeft = @"HRS LEFT";
static NSString *kMinutesLeft = @"MINS LEFT";
static NSString *kSecondsLeft = @"SECS LEFT";

static NSString *kWeeksToStart = @"WKS TO START";
static NSString *kDaysToStart = @"DAYS TO START";
static NSString *kHoursToStart = @"HRS TO START";
static NSString *kMinutesToStart = @"MINS TO START";
static NSString *kSecondsToStart = @"SECS TO START";

static NSString *kDone = @"DONE";

@implementation Event (Helper)

- (CGFloat)progress {
    if (self.startDate && self.endDate) {
        NSTimeInterval intervalSinceStart = [self.endDate timeIntervalSinceDate:self.startDate];
        NSTimeInterval intervalSinceNow = [[NSDate date] timeIntervalSinceDate:self.startDate];
        return intervalSinceNow / intervalSinceStart;
    } else {
        return 0;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name '%@', startDate '%@', endDate '%@', desc '%@', created '%@'", self.name, self.startDate, self.endDate, self.details, self.createdDate];
}

- (NSInteger)weeksLeftToDate:(NSDate *)date {
    return lroundf([self daysLeftToDate:date] / 7.0);
}

- (NSInteger)daysLeftToDate:(NSDate *)date {
    return lroundf([self hoursLeftToDate:date] / 24.0);
}

- (NSInteger)hoursLeftToDate:(NSDate *)date {
    return lroundf([self minutesLeftToDate:date] / 60.0);
}

- (NSInteger)minutesLeftToDate:(NSDate *)date {
    return lroundf([self secondsLeftToDate:date] / 60.0);
}

- (NSInteger)secondsLeftToDate:(NSDate *)date {
    return lroundf([date timeIntervalSinceDate:[NSDate date]]);
}

- (NSDictionary *)bestNumberAndText {
    NSString *progress;
    NSString *metaText;
    
    if ([self.startDate compare:[NSDate date]] == NSOrderedDescending) {
        // Start date is in the future
        if ([self weeksLeftToDate:self.startDate] > 2) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"weeks"]) {
            progress = [@([self weeksLeftToDate:self.startDate]) stringValue];
            metaText = kWeeksToStart;
            } else {
                progress = [@([self daysLeftToDate:self.startDate]) stringValue];
                metaText = kDaysToStart;
            }
        }
        else if ([self daysLeftToDate:self.startDate] > 2) {
            progress = [@([self daysLeftToDate:self.startDate]) stringValue];
            metaText = kDaysToStart;
        }
        else if ([self hoursLeftToDate:self.startDate] > 2) {
            progress = [@([self hoursLeftToDate:self.startDate]) stringValue];
            metaText = kHoursToStart;
        }
        else if ([self minutesLeftToDate:self.startDate] > 2) {
            progress = [@([self minutesLeftToDate:self.startDate]) stringValue];
            metaText = kMinutesToStart;
        }
        else if ([self secondsLeftToDate:self.startDate] > 0) {
            progress = [@([self secondsLeftToDate:self.startDate]) stringValue];
            metaText = kSecondsToStart;
        }
        else {
            progress = [@(0) stringValue];
            metaText = kDone;
        }
    } else {
        // Start date is in the past
        if ([self weeksLeftToDate:self.endDate] > 2) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"weeks"]) {
            progress = [@([self weeksLeftToDate:self.endDate]) stringValue];
            metaText = kWeeksLeft;
            } else {
                progress = [@([self daysLeftToDate:self.endDate]) stringValue];
                metaText = kDaysLeft;
            }
        }
        else if ([self daysLeftToDate:self.endDate] > 2) {
            progress = [@([self daysLeftToDate:self.endDate]) stringValue];
            metaText = kDaysLeft;
        }
        else if ([self hoursLeftToDate:self.endDate] > 2) {
            progress = [@([self hoursLeftToDate:self.endDate]) stringValue];
            metaText = kHoursLeft;
        }
        else if ([self minutesLeftToDate:self.endDate] > 2) {
            progress = [@([self minutesLeftToDate:self.endDate]) stringValue];
            metaText = kMinutesLeft;
        }
        else if ([self secondsLeftToDate:self.endDate] > 0) {
            progress = [@([self secondsLeftToDate:self.endDate]) stringValue];
            metaText = kSecondsLeft;
        }
        //Days Since
        else if ([self minutesLeftToDate:self.endDate] < 2) {
            progress = [@([self minutesLeftToDate:self.endDate]) stringValue];
            metaText = kMinutesSince;
        }
        else if ([self hoursLeftToDate:self.endDate] < 2) {
            progress = [@([self hoursLeftToDate:self.endDate]) stringValue];
            metaText = kHoursSince;
        }
        else if ([self daysLeftToDate:self.endDate] < 2) {
            progress = [@([self daysLeftToDate:self.endDate]) stringValue];
            metaText = kDaysLeft;
        }
        else {
            progress = @"✓";
            metaText = kDone;
        }
    }
    
    return @{@"number": progress,
             @"text" : metaText};
}

@end
