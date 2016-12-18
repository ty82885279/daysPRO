//
//  AddEventTableViewController.m
//  Time Left
//
//  Created by Salavat Khanov on 12/25/13.
//  Copyright (c) 2013 Salavat Khanov. All rights reserved.
//

#import "AddEventTableViewController.h"
#import "AppDelegate.h"

static NSInteger const kTextFieldSection = 0;
static NSInteger const kNameCellIndex = 0;
static NSInteger const kDescriptionCellIndex = 1;

static NSInteger const kDatePickerSection = 1;
static NSInteger const kStartDatePickerIndex = 1;
static NSInteger const kEndDatePickerIndex = 3;
static NSInteger const kDatePickerCellHeight = 216;

@interface AddEventTableViewController ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIColor *cellBackgroundColor;

@end

@implementation AddEventTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}
#pragma mark - Load and setup view
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLabels];
    [self signUpForKeyboardNotifications];
    [self setupColors];
    self.navigationItem.rightBarButtonItem.enabled = self.isEventEditMode;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.nameTextField becomeFirstResponder];
    [self setupDatePickers];
    _image = [self loadImage];
}
- (void)setupColors {
    ThemeManager *themeManager = [[ThemeManager alloc] init];
    NSDictionary *colors = [themeManager getTheme];
    // Table
    self.tableView.backgroundColor = [colors objectForKey:@"background"];
    self.tableView.tintColor = [colors objectForKey:@"tint"];
    self.cellBackgroundColor = [colors objectForKey:@"cellBackground"];
    // Nav bar
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [colors objectForKey:@"colorText"]};
    self.navigationController.navigationBar.barTintColor = [colors objectForKey:@"background"];
    // Light status bar
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // Text fields
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Name", nil)
                                                                               attributes:@{NSForegroundColorAttributeName : [colors objectForKey:@"background"]}];
    
    self.descriptionTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Description (optional)", nil)
                                                                                      attributes:@{NSForegroundColorAttributeName : [colors objectForKey:@"background"]}];
    
}
- (void)setupLabels {
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    if (self.isEventEditMode) {
        self.navigationItem.title = NSLocalizedString(@"Edit Event", nil);
        _nameTextField.text = _event.name;
        if (_event.details.length != 0) {
            _descriptionTextField.text = _event.details;
        }
        
        _startsDateLabel.text = [_dateFormatter stringFromDate:_event.startDate];
        _endsDateLabel.text = [_dateFormatter stringFromDate:_event.endDate];
    } else {
        self.navigationItem.title = NSLocalizedString(@"New Event", nil);
        NSDate *now = [NSDate date];
        _startsDateLabel.text = [self.dateFormatter stringFromDate:now];
        _endsDateLabel.text = NSLocalizedString(@"Choose...", nil);
    }
}
- (void)setupDatePickers {
    // Load Start Date picker
    self.startsDatePicker = [[UIDatePicker alloc] init];
    _startsDatePicker.hidden = YES;
    _startsDatePicker.tag = 0;
    _startsDatePicker.tintColor = [UIColor whiteColor];
    _startsDatePicker.date = (self.isEventEditMode) ? _event.startDate : [NSDate date];
    [_startsDatePicker addTarget:self action:@selector(pickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    NSIndexPath *startDatePickerIndexPath = [NSIndexPath indexPathForRow:kStartDatePickerIndex inSection:kDatePickerSection];
    UITableViewCell *startDatePickerCell = [self.tableView cellForRowAtIndexPath:startDatePickerIndexPath];
    [startDatePickerCell.contentView addSubview:_startsDatePicker];
    
    // Load End Date picker
    self.endsDatePicker = [[UIDatePicker alloc] init];
    _endsDatePicker.hidden = YES;
    _endsDatePicker.tag = 1;
    _endsDatePicker.tintColor = [UIColor whiteColor];
    [_endsDatePicker addTarget:self action:@selector(pickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    _endsDatePicker.minimumDate = (self.isEventEditMode) ? [_event.startDate dateByAddingTimeInterval:60] : [_startsDatePicker.date dateByAddingTimeInterval:60]; // add +60sec
    _endsDatePicker.date = (self.isEventEditMode) ? _event.endDate : _endsDatePicker.minimumDate;
    NSIndexPath *endDatePickerIndexPath = [NSIndexPath indexPathForRow:kEndDatePickerIndex inSection:kDatePickerSection];
    UITableViewCell *endDatePickerCell = [self.tableView cellForRowAtIndexPath:endDatePickerIndexPath];
    [endDatePickerCell.contentView addSubview:_endsDatePicker];
    
    // Reload cells with pickers in the table view
    [self.tableView reloadRowsAtIndexPaths:@[startDatePickerIndexPath, endDatePickerIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)signUpForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
}
# pragma mark - TableView Setup
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.tableView.rowHeight;
    // Set height = 0 for hidden date pickers
    if (indexPath.section == kDatePickerSection && indexPath.row == kStartDatePickerIndex) {
        height = (self.startsDatePicker.isHidden || self.startsDatePicker == nil) ? 0 : kDatePickerCellHeight;
    } else if (indexPath.section == kDatePickerSection && indexPath.row == kEndDatePickerIndex) {
        height =  (self.endsDatePicker.isHidden || self.endsDatePicker == nil) ? 0 : kDatePickerCellHeight;
    }
    return height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ((indexPath.row != kNameCellIndex) || (indexPath.section != kTextFieldSection) || (indexPath.row != kDescriptionCellIndex)) {
        [self.nameTextField resignFirstResponder];
        [self.descriptionTextField resignFirstResponder];
    }
    
    if (indexPath.row == kStartDatePickerIndex - 1 && indexPath.section == kDatePickerSection) {
        // Hide/show Start Date picker
        self.startsDatePicker.isHidden ? [self showCellForDatePicker:self.startsDatePicker] : [self hideCellForDatePicker:self.startsDatePicker];
        [self hideCellForDatePicker:self.endsDatePicker];
    } else if (indexPath.row == kEndDatePickerIndex - 1 && indexPath.section == kDatePickerSection) {
        // Hide/show End Date picker
        [self hideCellForDatePicker:self.startsDatePicker];
        self.endsDatePicker.isHidden ? [self showCellForDatePicker:self.endsDatePicker] : [self hideCellForDatePicker:self.endsDatePicker];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.backgroundColor = self.cellBackgroundColor;
}
#pragma mark - Show/Hide date pickers
- (void)showCellForDatePicker:(UIDatePicker *)datePicker {
    datePicker.hidden = NO;
    datePicker.alpha = 0.0f;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.38 animations:^{
        datePicker.alpha = 1.0f;
    }];
}
- (void)hideCellForDatePicker:(UIDatePicker *)datePicker {
    datePicker.hidden = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         datePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         datePicker.hidden = YES;
                     }];
}
- (IBAction)pickerDateChanged:(UIDatePicker *)sender {
    if (sender.tag == 0) {
        // Start Date Picker Changed
        _startsDateLabel.text = [_dateFormatter stringFromDate:sender.date];
        NSDate *laterDate = [_startsDatePicker.date laterDate:[NSDate date]];
        _endsDatePicker.minimumDate = [laterDate dateByAddingTimeInterval:60]; // add +60sec
    } else if (sender.tag == 1) {
        // End Date Picker Changed
        if (_endsDateLabel.text.length == 0) {
            _endsDateLabel.alpha = 0.0f;
            [UIView animateWithDuration:0.25
                             animations:^{
                                 _endsDateLabel.alpha = 1.0f;
                             }];
        }
    }
    _endsDateLabel.text = [_dateFormatter stringFromDate:_endsDatePicker.date];
}
- (IBAction)camera:(id)sender {
    UIImagePickerController *picker;
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = true;
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Add Image", nil)
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *takePicture = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Take a Picture", nil)
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                      picker.allowsEditing = false;
                                      [self presentViewController:picker animated:YES completion:nil];
                                  }];
    
    UIAlertAction *cameraRoll = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Select a Picture", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                     [self presentViewController:picker animated:YES completion:^{
                                         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
                                         picker.topViewController.title = NSLocalizedString(@"Select a Picture", nil);
                                         picker.navigationBar.translucent = NO;
                                         picker.allowsEditing = false;
                                         picker.navigationBar.barStyle = UIBarStyleDefault;
                                         [picker setNavigationBarHidden:NO animated:NO];
                                     }];
                                 }];
    
    UIAlertAction *removeImage = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Remove Image", nil)
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      //remove the image
                                      NSFileManager *fileManager = [NSFileManager defaultManager];
                                      NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                                      
                                      NSString *filePath = [documentsPath stringByAppendingPathComponent:self.event.uuid];
                                      NSError *error;
                                      [fileManager removeItemAtPath:filePath error:&error];
                                      _image = nil;
                                  }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:nil];
    [alertController addAction:takePicture];
    [alertController addAction:cameraRoll];
    
    //Only show the remove button if there's an image
    if ([self loadImage]) {
        [alertController addAction:removeImage];
    }
    
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - Show / Hide Save button
- (IBAction)nameTextFieldEditingChaged:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = (sender.text.length == 0) ? NO : YES;
}
#pragma mark - Cancel / Save
- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveButton:(id)sender {
    if (self.nameTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No Name", nil)];
    } else {
        
        if (self.isEventEditMode) {
            [[DataManager sharedManager] updateEvent:_event withName:_nameTextField.text
                                           startDate:_startsDatePicker.date endDate:_endsDatePicker.date details:_descriptionTextField.text image:_image];
            [[DataManager sharedManager] saveContext];
            
            [Answers logCustomEventWithName:@"Edit event" customAttributes:@{@"Name":_nameTextField.text}];
            
            [SVProgressHUD showSuccessWithStatus:nil];
        } else {
            [[DataManager sharedManager] createEventWithName:_nameTextField.text
                                                   startDate:_startsDatePicker.date endDate:_endsDatePicker.date details:_descriptionTextField.text image:_image];
            
            [[DataManager sharedManager] saveContext];
            [Answers logCustomEventWithName:@"Add event" customAttributes:@{@"Name":_nameTextField.text}];

            [SVProgressHUD showSuccessWithStatus:nil];
        }
        
        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? [self dismissViewControllerAnimated:YES completion:nil] : [self.popover dismissPopoverAnimated:YES];
        [SVProgressHUD showSuccessWithStatus:nil];
    }
}
- (void)keyboardWillShow {
    !self.startsDatePicker.isHidden ? [self hideCellForDatePicker:self.startsDatePicker] : nil;
    !self.endsDatePicker.isHidden ? [self hideCellForDatePicker:self.endsDatePicker] : nil;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.nameTextField]) {
        // Swith to description text field from name text field
        [self.nameTextField resignFirstResponder];
        [self.descriptionTextField becomeFirstResponder];
    } else {
        [self.descriptionTextField resignFirstResponder];
        // Show the firts date picker and hide the second one
        [self showCellForDatePicker:self.startsDatePicker];
        [self hideCellForDatePicker:self.endsDatePicker];
    }
    return YES;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self saveImage:image];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveImage:(UIImage *)image {
    if (image != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:self.event.uuid];
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
        _image = image;
    }
}

- (UIImage *)loadImage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:self.event.uuid];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

@end
