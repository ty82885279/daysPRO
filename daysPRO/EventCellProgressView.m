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

static CGFloat kNumberInsideCircleFontSizeiPhone = 35.0;
static CGFloat kNumberInsideCircleFontSizeiPad = 50.0;
static NSString *kSymbolFontName = @"AppleSDGothicNeo-Regular";
static CGFloat kSymbolFontSize = 45.0;

@implementation EventCellProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupColors];
}
- (void)setupColors {
    ThemeManager *themeManager = [[ThemeManager alloc] init];
    NSDictionary *colors = [themeManager getTheme];
    self.backgroundColor = [colors objectForKey:@"background"];
    self.circleBackgroundColor = [colors objectForKey:@"innerCircleBackground"];
    self.circleProgressColor = [colors objectForKey:@"innerCircleProgress"];
    self.progressLabel.textColor = [colors objectForKey:@"colorText"];
    self.metaLabel.textColor = [colors objectForKey:@"colorText"];
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
- (void)useSmallerFont {
    self.progressLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kNumberInsideCircleFontSizeiPhone : kNumberInsideCircleFontSizeiPad];
    
    self.metaLabel.numberOfLines = 1;
    self.metaLabel.minimumScaleFactor = 8./self.metaLabel.font.pointSize;
    self.metaLabel.adjustsFontSizeToFitWidth = YES;
}
- (void)useFontForSymbol {
    self.progressLabel.font = [UIFont fontWithName:kSymbolFontName size:kSymbolFontSize];
}
- (void)useDefaultFont {
    self.progressLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kNumberInsideCircleFontSizeiPhone : kNumberInsideCircleFontSizeiPad];

    self.metaLabel.numberOfLines = 1;
    self.metaLabel.minimumScaleFactor = 8./self.metaLabel.font.pointSize;
    self.metaLabel.adjustsFontSizeToFitWidth = YES;
}

@end
