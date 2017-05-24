//
//  Event+Helper.m
//  Time Left
//
//  Created by Salavat Khanov on 1/25/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "Event+Helper.h"

@implementation Event (Helper)

- (NSDate *)date {
    return self.startDate;
}

- (void)setDate:(NSDate *)date {
    self.startDate = date;
}

- (UIImage *)image {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:self.uuid];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (CGFloat)progress {
    if (self.date && self.date) {
        NSTimeInterval intervalSinceStart = [self.date timeIntervalSinceDate:self.date];
        NSTimeInterval intervalSinceNow = [[NSDate date] timeIntervalSinceDate:self.date];
        return intervalSinceNow / intervalSinceStart;
    } else {
        return 0;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name '%@', date '%@', date '%@', desc '%@', created '%@'", self.name, self.date, self.date, self.details, self.createdDate];
}

- (BOOL)isOver {
    return self.progress > 1;
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
    NSInteger progress;
    NSString *metaText;
    
    if ([self.date compare:[NSDate date]] == NSOrderedDescending) {
        // Start date is in the future
        if ([self weeksLeftToDate:self.date] > 2) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"weeks"]) {
                progress = [self weeksLeftToDate:self.date];
                metaText = NSLocalizedString(@"WEEKS UNTIL", nil);
            } else {
                progress = [self daysLeftToDate:self.date];
                metaText = NSLocalizedString(@"DAYS UNTIL", nil);
            }
        } else if ([self daysLeftToDate:self.date] > 2) {
            progress = [self daysLeftToDate:self.date];
            metaText = NSLocalizedString(@"DAYS UNTIL", nil);
        } else if ([self hoursLeftToDate:self.date] > 2) {
            progress = [self hoursLeftToDate:self.date];
            metaText = NSLocalizedString(@"HOURS UNTIL", nil);
        } else if ([self minutesLeftToDate:self.date] > 2) {
            progress = [self minutesLeftToDate:self.date];
            metaText = NSLocalizedString(@"MINS UNTIL", nil);
        } else if ([self secondsLeftToDate:self.date] > 0) {
            progress = [self secondsLeftToDate:self.date];
            metaText = NSLocalizedString(@"SECS UNTIL", nil);
        } else {
            progress = 0;
            metaText = NSLocalizedString(@"DONE", nil);
        }
    } else {
        // Start date is in the past
        // Use labs() to convert -1 to 1
        if ([self isOver]) {
            if (labs([self daysLeftToDate:self.date]) > 2) {
                progress = [self daysLeftToDate:self.date];
                metaText = NSLocalizedString(@"DAYS SINCE", nil);
            } else if (labs([self hoursLeftToDate:self.date]) > 2) {
                progress = [self hoursLeftToDate:self.date];
                metaText = NSLocalizedString(@"HOURS SINCE", nil);
            } else if (labs([self minutesLeftToDate:self.date]) > 2) {
                progress = [self minutesLeftToDate:self.date];
                metaText = NSLocalizedString(@"MINS SINCE", nil);
            } else {
                progress = [self secondsLeftToDate:self.date];
                metaText = NSLocalizedString(@"SECS SINCE", nil);
            }
            return @{@"number": [NSString stringWithFormat:@"%li", (long)labs(progress)],
                     @"text" : metaText};
        }
        
        if ([self weeksLeftToDate:self.date] > 2) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"weeks"]) {
                progress = [self weeksLeftToDate:self.date];
                metaText = NSLocalizedString(@"WKS LEFT", nil);
            } else {
                progress = [self daysLeftToDate:self.date];
                metaText = NSLocalizedString(@"DAYS LEFT", nil);
            }
        } else if ([self daysLeftToDate:self.date] > 2) {
            progress = [self daysLeftToDate:self.date];
            metaText = NSLocalizedString(@"DAYS LEFT", nil);
        } else if ([self hoursLeftToDate:self.date] > 2) {
            progress = [self hoursLeftToDate:self.date];
            metaText = NSLocalizedString(@"HOURS LEFT", nil);
        } else if ([self minutesLeftToDate:self.date] > 2) {
            progress = [self minutesLeftToDate:self.date];
            metaText = NSLocalizedString(@"MINS LEFT", nil);
        } else if ([self secondsLeftToDate:self.date] > 0) {
            progress = [self secondsLeftToDate:self.date];
            metaText = NSLocalizedString(@"SECS LEFT", nil);
        } else {
            progress = 0;
            metaText = NSLocalizedString(@"DONE", nil);
        }
    }
    
    return @{@"number": [NSString stringWithFormat:@"%li", (long)labs(progress)],
             @"text" : metaText};
}

@end
