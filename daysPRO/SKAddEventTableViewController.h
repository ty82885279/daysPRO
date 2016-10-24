//
//  SKAddEventTableViewController.h
//  Time Left
//
//  Created by Salavat Khanov on 12/25/13.
//  Copyright (c) 2013 Salavat Khanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKDataManager.h"

@interface SKAddEventTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *startsDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endsDateLabel;

@property (strong, nonatomic) UIDatePicker *startsDatePicker;
@property (strong, nonatomic) UIDatePicker *endsDatePicker;

@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) SKEvent *event;
@property (assign, nonatomic, getter = isEventEditMode) BOOL eventEditMode;

- (IBAction)cancelButton:(id)sender;
- (IBAction)saveButton:(id)sender;

@end
