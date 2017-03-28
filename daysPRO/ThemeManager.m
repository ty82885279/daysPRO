//
//  ThemeManager.m
//  Days Pro
//
//  Created by Oliver Kulpakko on 2016-10-24.
//  Copyright © 2016 Oliver Kulpakko. All rights reserved.
//

#import "ThemeManager.h"

@implementation ThemeManager

+ (UIColor *)getBackgroundColor {
    return [self getColorForColor:@"backgroundColor"];
}
+ (UIColor *)getThemeColor {
    return [self getColorForColor:@"themeColor"];
}
+ (UIColor *)getCircleBackgroundColor {
    return [self getColorForColor:@"circleBackgroundColor"];
}
+ (UIColor *)getColorForColor:(NSString *)colorName {
    unsigned rgbValue = 0;
    NSString *savedColor = [[NSUserDefaults standardUserDefaults] stringForKey:colorName];
    NSScanner *scanner = [NSScanner scannerWithString:savedColor];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
