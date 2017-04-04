//
//  EventCellProgressView.h
//  Time Left
//
//  Created by Salavat Khanov on 1/23/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCellProgressView : UIView

@property (assign, nonatomic) CGFloat percentCircle;

@property (strong, nonatomic) UIColor *circleBackgroundColor;
@property (strong, nonatomic) UIColor *circleProgressColor;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *metaLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
