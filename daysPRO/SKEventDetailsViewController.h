//
//  SKEventDetailsViewController.h
//  Time Left
//
//  Created by Salavat Khanov on 1/20/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKProgressIndicator.h"
#import "SKEvent.h"
#import "SKEvent+Helper.h"

@interface SKEventDetailsViewController : UIViewController

@property (strong, nonatomic) SKEvent *event;

@end
