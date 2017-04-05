//
//  ProgressIndicator.m
//  Time Left
//
//  Created by Salavat Khanov on 1/21/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "ProgressIndicator.h"
#import "AppDelegate.h"

static NSInteger kInnerCircleRadiusiPhone = 117;
static NSInteger kInnerCircleRadiusiPad = 167;
static NSInteger kInnnerCircleLineWidthiPhone = 22;
static NSInteger kInnnerCircleLineWidthiPad = 22;

static NSString *kRotationAnimationKey = @"strokeEnd";
static NSString *kColorAnimationKey = @"strokeColor";

@interface ProgressIndicator ()
@end

@implementation ProgressIndicator

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupColors];
    UIImpactFeedbackGenerator *taptic = [[UIImpactFeedbackGenerator alloc] init];
    [taptic prepare];
}

- (void)setupColors {
    self.backgroundColor = [UIColor clearColor];
    self.circleBackgroundColor = [ThemeManager getCircleBackgroundColor];
    self.themeColor = [ThemeManager getThemeColor];
    self.textInsideCircleColor = [ThemeManager getThemeColor];
    self.progressLabel.textColor = self.textInsideCircleColor;
    self.metaLabel.textColor = self.textInsideCircleColor;
}

- (void)drawRect:(CGRect)rect {
    // Draw circles
    [self drawInnerCircleBackgroundIn:rect];
    [self drawInnerCircleProgress:self.percentInnerCircle inRect:rect];
}

#pragma mark - Draw Circles
- (void)drawInnerCircleBackgroundIn:(CGRect)rect {
    self.circlePath = [UIBezierPath bezierPath];
    [self.circlePath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kInnerCircleRadiusiPhone : kInnerCircleRadiusiPad
                      startAngle:0
                        endAngle:M_PI * 2
                       clockwise:YES];
    
    self.circlePath.lineWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kInnnerCircleLineWidthiPhone : kInnnerCircleLineWidthiPad;
    [self.circleBackgroundColor setStroke];
    [self.circlePath stroke];
    
    CGRect frame = _circlePath.bounds;
    frame.size.height = frame.size.height - 20;
    frame.size.width = frame.size.width - 20;
    frame.origin.x = frame.origin.x + 10;
    frame.origin.y = frame.origin.y + 10;
    
    UIVisualEffect *blurEffect;
    if ([ThemeManager darkMode]) {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    } else {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    }
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = frame;
    
    visualEffectView.layer.cornerRadius = visualEffectView.frame.size.width / 2;
    visualEffectView.clipsToBounds = YES;
    
    if (!_blurAdded) {
        [self insertSubview:visualEffectView atIndex:0];
        _blurAdded = true;
    }
}

- (void)drawInnerCircleProgress:(CGFloat)percent inRect:(CGRect)rect {
    [NSTimer scheduledTimerWithTimeInterval: 0.75
                                                  target: self
                                                selector:@selector(prepareTapticEngine)
                                                userInfo: nil repeats:true];
    UISelectionFeedbackGenerator *taptic = [[UISelectionFeedbackGenerator alloc] init];
    
    CGFloat startAngle = M_PI * 1.5;
    CGFloat endAngle = startAngle + (M_PI * 2);
    
    if (percent > 100) {
        percent = 100;
    } else {
        [taptic selectionChanged];
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kInnerCircleRadiusiPhone : kInnerCircleRadiusiPad
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * (percent / 100.0) + startAngle
                       clockwise:YES];
    
    bezierPath.lineWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kInnnerCircleLineWidthiPhone : kInnnerCircleLineWidthiPad;
    [self.themeColor setStroke];
    [bezierPath stroke];
}

- (void)prepareTapticEngine {
    UISelectionFeedbackGenerator *taptic = [[UISelectionFeedbackGenerator alloc] init];
    [taptic prepare];
}

- (UIBezierPath *)getCircleBezierPath {
    return _circlePath;
}
@end
