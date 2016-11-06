//
//  ThemeManager.m
//  Days Pro
//
//  Created by Oliver Kulpakko on 2016-10-24.
//  Copyright © 2016 Salavat Khanov. All rights reserved.
//

#import "ThemeManager.h"

@implementation ThemeManager

- (NSDictionary *)getTheme {
    NSDictionary *colors;
    
    colors = @{@"background"            : [self getBackgroundColor],
               @"tint"                  : [self getTintColor],
               @"colorText"             : [self getTextColor],
               @"innerCircleProgress"   : [self getInnerCircleProgressColor],
               @"innerCircleBackground" : [self getInnerCircleBackgroundColor],
               @"cellBackground"        : [self getCellBackgroundColor]};
    
    return colors;
}

- (UIColor *)getBackgroundColor {
    return [self getColorForColor:@"backgroundColor"];
}

- (UIColor *)getTintColor {
    return [self getColorForColor:@"tintColor"];
}

- (UIColor *)getTextColor {
    return [self getColorForColor:@"textColor"];
}

- (UIColor *)getInnerCircleProgressColor {
    return [self getColorForColor:@"innerCircleProgressColor"];
}

- (UIColor *)getInnerCircleBackgroundColor {
    return [self getColorForColor:@"innerCircleBackgroundColor"];
}

- (UIColor *)getCellBackgroundColor {
    return [self getColorForColor:@"cellBackgroundColor"];
}

- (UIColor *)getColorForColor:(NSString *)colorName {
    unsigned rgbValue = 0;
    NSString *savedColor = [[NSUserDefaults standardUserDefaults] stringForKey:colorName];
    NSScanner *scanner = [NSScanner scannerWithString:savedColor];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)setTheme {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"202020" forKey:@"backgroundColor"];
    [defaults setObject:@"F1B033" forKey:@"tintColor"];
    [defaults setObject:@"FEB934" forKey:@"textColor"];
    [defaults setObject:@"EA8125" forKey:@"innerCircleProgressColor"];
    [defaults setObject:@"525252" forKey:@"innerCircleBackgroundColor"];
    [defaults setObject:@"5C5C5C" forKey:@"cellBackgroundColor"];
    
    if ([self isDate:[NSDate date] inRangeFirstDate:[self firstDayOfDec] lastDate:[self lastDayOfDec]]) {
        [self enableDecemberTheme];
    }
}

#pragma mark Christmas
- (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    return [date compare:firstDate] == NSOrderedDescending &&
    [date compare:lastDate]  == NSOrderedAscending;
}

- (NSDate *)firstDayOfDec {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:12];
    [comps setYear:[self getCurrentYear]];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
    
}
- (NSDate *)lastDayOfDec {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:31];
    [comps setMonth:12];
    [comps setYear:[self getCurrentYear]];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
    
}
- (int)getCurrentYear {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    return yearString.intValue;
}
- (void)enableDecemberTheme {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"202020" forKey:@"backgroundColor"];
    [defaults setObject:@"E74C3C" forKey:@"tintColor"];
    [defaults setObject:@"E74C3C" forKey:@"textColor"];
    [defaults setObject:@"E74C3C" forKey:@"innerCircleProgressColor"];
    [defaults setObject:@"525252" forKey:@"innerCircleBackgroundColor"];
    [defaults setObject:@"34495E" forKey:@"cellBackgroundColor"];
}

@end
