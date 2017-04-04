//
//  ThemeManager.h
//  Days Pro
//
//  Created by Oliver Kulpakko on 2016-10-24.
//  Copyright © 2016 Oliver Kulpakko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeManager : NSObject

+ (UIColor *)getBackgroundColor;
+ (UIColor *)getThemeColor;
+ (UIColor *)getCircleBackgroundColor;
+ (UIColor *)getTextColor;
+ (BOOL)darkMode;

@end
