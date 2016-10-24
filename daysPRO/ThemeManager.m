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
               @"outerCircleProgress"   : [self getOuterCircleProgressColor],
               @"outerCircleBackground" : [self getOuterCircleBackgroundColor],
               @"innerCircleProgress"   : [self getInnerCircleProgressColor],
               @"innerCircleBackground" : [self getInnerCircleBackgroundColor],
               @"cellBackground"        : [self getCellBackgroundColor]};
    
    return colors;
}

- (UIColor *)getBackgroundColor {
    return [UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1.0];
}

- (UIColor *)getTintColor {
    return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
}

- (UIColor *)getTextColor {
    return [UIColor colorWithRed:254.0/255.0 green:185.0/255.0 blue:52.0/255.0 alpha:1.0];
}

- (UIColor *)getOuterCircleProgressColor {
    return [UIColor colorWithRed:241.0/255.0 green:176.0/255.0 blue:51.0/255.0 alpha:1.0];
}

- (UIColor *)getOuterCircleBackgroundColor {
    return [UIColor colorWithRed:241.0/255.0 green:176.0/255.0 blue:51.0/255.0 alpha:1.0];
}

- (UIColor *)getInnerCircleProgressColor {
    return [UIColor colorWithRed:234.0/255.0 green:129.0/255.0 blue:37.0/255.0 alpha:1.0];
}

- (UIColor *)getInnerCircleBackgroundColor {
    return [UIColor colorWithRed:82.0/255.0 green:82.0/255.0 blue:82.0/255.0 alpha:1.0];
}

- (UIColor *)getCellBackgroundColor {
    return [UIColor colorWithRed:92.0/255.0 green:92.0/255.0 blue:92.0/255.0 alpha:1.0];
}

@end
