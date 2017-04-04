//
//  EventCellProgressView.m
//  Time Left
//
//  Created by Salavat Khanov on 1/23/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "EventCellProgressView.h"
#import "AppDelegate.h"

static NSInteger kCircleRadiusiPhone = 54;
static NSInteger kCircleRadiusiPad = 80;
static NSInteger kCircleLineWidth = 3;

@implementation EventCellProgressView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupColors];
}
- (void)setupColors {
    self.backgroundColor = [ThemeManager getBackgroundColor];
    self.circleBackgroundColor = [ThemeManager getCircleBackgroundColor];
    self.circleProgressColor = [ThemeManager getThemeColor];
    self.progressLabel.textColor = [ThemeManager getThemeColor];
    self.metaLabel.textColor = [ThemeManager getThemeColor];
    self.dateLabel.textColor = [ThemeManager getThemeColor];
}
- (void)drawRect:(CGRect)rect {
    CGFloat startAngle = M_PI * 1.5;
    CGFloat endAngle = startAngle + (M_PI * 2.0);
    
    // Draw background
    UIBezierPath *backgroundBezierPath = [UIBezierPath bezierPath];
    [backgroundBezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                                    radius:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kCircleRadiusiPhone : kCircleRadiusiPad
                                startAngle:startAngle
                                  endAngle:endAngle
                                 clockwise:YES];
    backgroundBezierPath.lineWidth = kCircleLineWidth;
    self.percentCircle < 100 ? [self.circleBackgroundColor setStroke] : [self.circleProgressColor setStroke];
    [backgroundBezierPath stroke];
    
    // Draw progress
    if (self.percentCircle < 100) {
        UIBezierPath *progressBezierPath = [UIBezierPath bezierPath];
        [progressBezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                                      radius:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kCircleRadiusiPhone : kCircleRadiusiPad
                                  startAngle:startAngle
                                    endAngle:(endAngle - startAngle) * (self.percentCircle / 100.0) + startAngle
                                   clockwise:YES];
        progressBezierPath.lineWidth = kCircleLineWidth;
        [self.circleProgressColor setStroke];
        [progressBezierPath stroke];
    }
}

@end
