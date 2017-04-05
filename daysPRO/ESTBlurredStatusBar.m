//
//  ESTBlurredStatusBar.m
//  Days Pro
//
//  Created by Oliver Kulpakko on 2016-12-14.
//  Copyright © 2016 Oliver Kulpakko. All rights reserved.
//

#import "ESTBlurredStatusBar.h"

@implementation ESTBlurredStatusBar

- (id)initWithStyle:(UIBlurEffectStyle)style {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIApplication sharedApplication].statusBarFrame.size.height)];
    if (self) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:style];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        [effectView setFrame:self.bounds];
        [self addSubview:effectView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotated:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedFrame:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    
    return self;
}

- (void)rotated:(NSNotification *)notification {
    int number = [[notification.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
    if (number == UIInterfaceOrientationPortrait || number == UIInterfaceOrientationPortraitUpsideDown){
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0;
        }];
    }
}

- (void)changedFrame:(NSNotification *)notification {
    NSValue *value = [notification.userInfo objectForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect newRect = [value CGRectValue];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, newRect.size.width, newRect.size.height)];
    }];
}

@end
