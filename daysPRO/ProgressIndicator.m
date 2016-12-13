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
    ThemeManager *themeManager = [[ThemeManager alloc] init];
    NSDictionary *colors = [themeManager getTheme];
    
    self.backgroundColor = [UIColor clearColor];
    self.innerCircleBackgroundColor = [colors objectForKey:@"innerCircleBackground"];
    self.innerCircleProgressColor = [colors objectForKey:@"innerCircleProgress"];
    self.textInsideCircleColor = [colors objectForKey:@"tint"];
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
    _circlePath = [UIBezierPath bezierPath];
    [_circlePath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kInnerCircleRadiusiPhone : kInnerCircleRadiusiPad
                      startAngle:0
                        endAngle:M_PI * 2
                       clockwise:YES];
    
    _circlePath.lineWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kInnnerCircleLineWidthiPhone : kInnnerCircleLineWidthiPad;
    [self.innerCircleBackgroundColor setStroke];
    [_circlePath stroke];
}

- (void)drawInnerCircleProgress:(CGFloat)percent inRect:(CGRect)rect {
    [NSTimer scheduledTimerWithTimeInterval: 0.90
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
    [self.innerCircleProgressColor setStroke];
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
