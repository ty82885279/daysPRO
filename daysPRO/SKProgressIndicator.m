//
//  SKProgressIndicator.m
//  Time Left
//
//  Created by Salavat Khanov on 1/21/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "SKProgressIndicator.h"
#import "SKAppDelegate.h"

static NSInteger kInnerCircleRadiusiPhone = 117;
static NSInteger kInnerCircleRadiusiPad = 167;
static NSInteger kInnnerCircleLineWidthiPhone = 22;
static NSInteger kInnnerCircleLineWidthiPad = 22;

static NSInteger kOuterCircleRadiusiPhone = 138;
static NSInteger kOuterCircleRadiusiPad = 188;
static CGFloat kOuterCircleLineWidthiPhone = 2.5;
static CGFloat kOuterCircleLineWidthiPad = 2.5;

static NSString *kRotationAnimationKey = @"strokeEnd";
static NSString *kColorAnimationKey = @"strokeColor";

@interface SKProgressIndicator ()
@property (nonatomic, weak) CAShapeLayer *outerCirclePathLayer;
@property (nonatomic, weak) CAGradientLayer *outerCircleGradientLayer;
@end

@implementation SKProgressIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupColors];
}

- (void)setupColors
{
    SKAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSDictionary *colors = [delegate currentTheme];
    
    self.backgroundColor = [colors objectForKey:@"background"];
    self.innerCircleBackgroundColor = [colors objectForKey:@"innerCircleBackground"];
    self.innerCircleProgressColor = [colors objectForKey:@"innerCircleProgress"];
    self.outerCircleBackgroundColor = [colors objectForKey:@"outerCircleBackground"];
    self.outerCircleProgressColor = [colors objectForKey:@"outerCircleProgress"];
    self.textInsideCircleColor = [colors objectForKey:@"tint"];
}

- (void)drawRect:(CGRect)rect
{
    // Draw circles
    [self drawInnerCircleBackgroundIn:rect];
    [self drawInnerCircleProgress:self.percentInnerCircle inRect:rect];
    [self drawOuterCircleBackgroundIn:rect];
    [self drawOuterCircleProgress:self.percentInnerCircle inRect:rect];
}

#pragma mark - Draw Circles

- (void)drawInnerCircleBackgroundIn:(CGRect)rect
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kInnerCircleRadiusiPhone : kInnerCircleRadiusiPad
                      startAngle:0
                        endAngle:M_PI * 2
                       clockwise:YES];
    
    bezierPath.lineWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kInnnerCircleLineWidthiPhone : kInnnerCircleLineWidthiPad;
    [self.innerCircleBackgroundColor setStroke];
    [bezierPath stroke];
}

- (void)drawInnerCircleProgress:(CGFloat)percent inRect:(CGRect)rect
{
    CGFloat startAngle = M_PI * 1.5;
    CGFloat endAngle = startAngle + (M_PI * 2);
    
    if (percent > 100) {
        percent = 100;
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

- (void)drawOuterCircleBackgroundIn:(CGRect)rect
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kOuterCircleRadiusiPhone : kOuterCircleRadiusiPad
                      startAngle:0
                        endAngle:M_PI * 2
                       clockwise:YES];
    bezierPath.lineWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kOuterCircleLineWidthiPhone : kOuterCircleLineWidthiPad;
    [self.outerCircleBackgroundColor setStroke];
    [bezierPath stroke];
}

- (void)drawOuterCircleProgress:(CGFloat)percent inRect:(CGRect)rect
{
    if (percent >= 100) {
        [self doneOuterCircleAnimation];
    } else {
        [self progressOuterCircleAnimation];
    }
}

- (void)progressOuterCircleAnimation
{
    // If the shape layer doesn't exist, create it
    if (self.outerCirclePathLayer == nil) {
        
        // Create path
        CGFloat startAngle = M_PI * 1.5;
        CGFloat endAngle = startAngle + (M_PI * 2);
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath addArcWithCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)
                              radius:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kOuterCircleRadiusiPhone : kOuterCircleRadiusiPad
                          startAngle:startAngle
                            endAngle:endAngle
                           clockwise:YES];
        
        // Shape layer setup
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = bezierPath.CGPath;
        shapeLayer.strokeColor = self.outerCircleProgressColor.CGColor;
        shapeLayer.fillColor = nil;
        shapeLayer.lineWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kOuterCircleLineWidthiPhone : kOuterCircleLineWidthiPad;
        shapeLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:shapeLayer];
        self.outerCirclePathLayer = shapeLayer;
    }
    
    if (self.outerCircleGradientLayer.superlayer == nil) {
        
        [self.outerCirclePathLayer removeAllAnimations];
        
        // Gradient layer
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        gradientLayer.colors = @[(__bridge id)self.outerCircleProgressColor.CGColor,
                                 (__bridge id)self.innerCircleBackgroundColor.CGColor,
                                 (__bridge id)self.innerCircleBackgroundColor.CGColor,
                                 (__bridge id)self.innerCircleBackgroundColor.CGColor];
        gradientLayer.startPoint = CGPointMake(0,0.5);
        gradientLayer.endPoint = CGPointMake(1,0.5);
        [self.layer addSublayer:gradientLayer];
        gradientLayer.mask = self.outerCirclePathLayer;
        self.outerCircleGradientLayer = gradientLayer;
        
        // Animation
        CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotateAnimation.duration = 1.2;
        rotateAnimation.repeatCount = INFINITY;
        rotateAnimation.fromValue = @(0.0f);
        rotateAnimation.toValue = @((360*M_PI)/180);
        rotateAnimation.removedOnCompletion = NO;
        
        [gradientLayer addAnimation:rotateAnimation forKey:@"transform.rotation"];
    }
}

- (void)doneOuterCircleAnimation
{
    if (self.outerCirclePathLayer == nil) {
        CGFloat startAngle = M_PI * 1.5;
        CGFloat endAngle = startAngle + (M_PI * 2);
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath addArcWithCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)
                              radius:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kOuterCircleRadiusiPhone : kOuterCircleRadiusiPad
                          startAngle:startAngle
                            endAngle:endAngle
                           clockwise:YES];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = bezierPath.CGPath;
        shapeLayer.strokeColor = self.outerCircleProgressColor.CGColor;
        shapeLayer.fillColor = nil;
        shapeLayer.lineWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? kOuterCircleLineWidthiPhone : kOuterCircleLineWidthiPad;;
        shapeLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:shapeLayer];
        self.outerCirclePathLayer = shapeLayer;
    }
    
    if ([self.outerCirclePathLayer animationForKey:kColorAnimationKey] == nil) {
        
        [self.outerCirclePathLayer removeAllAnimations];
        [self.outerCircleGradientLayer removeFromSuperlayer];
        
        // Add new animation
        CGFloat duration = 1.5;
        CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:kColorAnimationKey];
        strokeAnimation.duration = duration;
        strokeAnimation.repeatCount = INFINITY;
        strokeAnimation.autoreverses = YES;
        strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        strokeAnimation.fromValue = (id)self.outerCircleProgressColor.CGColor;
        strokeAnimation.toValue = (id)self.outerCircleBackgroundColor.CGColor;
        strokeAnimation.removedOnCompletion = NO;
        
        [self.outerCirclePathLayer addAnimation:strokeAnimation forKey:kColorAnimationKey];
    }
}

@end
