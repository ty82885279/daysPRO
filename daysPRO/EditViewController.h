//
//  EditViewController.h
//  Days Pro
//
//  Created by Oliver Kulpakko on 2017-01-15.
//  Copyright © 2017 Salavat Khanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "DataManager.h"
#import "ThemeManager.h"

@interface EditViewController : UIViewController <UIImagePickerControllerDelegate>

@property BOOL isEditing;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *eventImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) Event *event;

@end
