//
//  EventDetailsViewController.h
//  Time Left
//
//  Created by Salavat Khanov on 1/20/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressIndicator.h"
#import "Event.h"
#import "Event+Helper.h"
#import "EditViewController.h"

@interface EventDetailsViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) Event *event;

@end
