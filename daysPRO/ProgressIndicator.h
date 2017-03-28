//
//  ProgressIndicator.h
//  Time Left
//
//  Created by Salavat Khanov on 1/21/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressIndicator : UIView

@property UIBezierPath *circlePath;
@property BOOL blurAdded;

@property (assign, nonatomic) CGFloat percentInnerCircle;
@property (strong, nonatomic) UIColor *circleBackgroundColor;
@property (strong, nonatomic) UIColor *themeColor;
@property (strong, nonatomic) UIColor *textInsideCircleColor;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *metaLabel;

- (UIBezierPath *)getCircleBezierPath;

@end
