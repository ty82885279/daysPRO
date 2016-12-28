//
//  ThemeManager.m
//  Days Pro
//
//  Created by Oliver Kulpakko on 2016-10-24.
//  Copyright © 2016 Oliver Kulpakko. All rights reserved.
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
    if (![defaults boolForKey:@"disableThemeReload"]) {
        [defaults setObject:@"202020" forKey:@"backgroundColor"];
        
        [defaults setObject:@"C59849" forKey:@"tintColor"];
        [defaults setObject:@"C59849" forKey:@"textColor"];
        
        [defaults setObject:@"C73E1D" forKey:@"innerCircleProgressColor"];
        [defaults setObject:@"522A27" forKey:@"innerCircleBackgroundColor"];
        
        [defaults setObject:@"522A27" forKey:@"cellBackgroundColor"];
    }
}
- (int)getCurrentYear {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    return yearString.intValue;
}

@end
