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

static NSString *const kNameTextFieldPlaceholder = @"Name";
static NSString *const kDescriptionTextFieldTextFieldPlaceholder = @"Description (optional)";
static NSString *const kEndsDateDefaultString = @"Choose...";

static NSString *const kErrorEmptyNameTitle = @"Empty Name";
static NSString *const kErrorEmptyNameMessage = @"Please give a name to the event.";
static NSString *const kErrorEmptyNameCancel = @"OK";

static NSString *const kAddEventScreenName = @"Add Event";
static NSString *const kEditEventScreenName = @"Edit Event";


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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupColors {
    ThemeManager *themeManager = [[ThemeManager alloc] init];
    NSDictionary *colors = [themeManager getTheme];
    // Table
    self.tableView.backgroundColor = [colors objectForKey:@"background"];
    self.tableView.tintColor = [colors objectForKey:@"tint"];
    self.cellBackgroundColor = [colors objectForKey:@"cellBackground"];
    self.startsDateLabel.textColor = [colors objectForKey:@"tint"];
    self.endsDateLabel.textColor = [colors objectForKey:@"tint"];
    // Nav bar
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [colors objectForKey:@"colorText"]};
    self.navigationController.navigationBar.barTintColor = [colors objectForKey:@"background"];
    // Light status bar
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // Text fields
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kNameTextFieldPlaceholder
                                                                               attributes:@{NSForegroundColorAttributeName : [colors objectForKey:@"background"]}];
    
    self.descriptionTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kDescriptionTextFieldTextFieldPlaceholder
                                                                                      attributes:@{NSForegroundColorAttributeName : [colors objectForKey:@"background"]}];
    self.nameTextField.textColor = [colors objectForKey:@"tint"];
    self.descriptionTextField.textColor = [colors objectForKey:@"tint"];
    
}

- (void)setupLabels {
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    if (self.isEventEditMode) {
        
        self.navigationItem.title = @"Edit Event";
        _nameTextField.text = _event.name;
        if (_event.details.length != 0) {
            _descriptionTextField.text = _event.details;
        }
        
        _startsDateLabel.text = [_dateFormatter stringFromDate:_event.startDate];
        _endsDateLabel.text = [_dateFormatter stringFromDate:_event.endDate];
        
    } else {
        
        NSDate *now = [NSDate date];
        _startsDateLabel.text = [self.dateFormatter stringFromDate:now];
        _endsDateLabel.text = kEndsDateDefaultString;
    }
    
    _startsDateLabel.textColor = [self.tableView tintColor];
    _endsDateLabel.textColor = [self.tableView tintColor];
}

- (void)setupDatePickers {
    // Load Start Date picker
    self.startsDatePicker = [[UIDatePicker alloc] init];
    _startsDatePicker.hidden = YES;
    _startsDatePicker.tag = 0;
    _startsDatePicker.date = (self.isEventEditMode) ? _event.startDate : [NSDate date];
    [_startsDatePicker addTarget:self action:@selector(pickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    NSIndexPath *startDatePickerIndexPath = [NSIndexPath indexPathForRow:kStartDatePickerIndex inSection:kDatePickerSection];
    UITableViewCell *startDatePickerCell = [self.tableView cellForRowAtIndexPath:startDatePickerIndexPath];
    [startDatePickerCell.contentView addSubview:_startsDatePicker];
    
    // Load End Date picker
    self.endsDatePicker = [[UIDatePicker alloc] init];
    _endsDatePicker.hidden = YES;
    _endsDatePicker.tag = 1;
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
                     completion:^(BOOL finished){
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
        [SVProgressHUD showErrorWithStatus:@"No name"];
    }
    else {
        
        if (self.isEventEditMode) {
            Event *updatedEvent = [[DataManager sharedManager] updateEvent:_event
                                                                  withName:_nameTextField.text
                                                                 startDate:_startsDatePicker.date
                                                                   endDate:_endsDatePicker.date
                                                                   details:_descriptionTextField.text];
            [[DataManager sharedManager] saveContext];
            NSLog(@"Saved updated event: %@", updatedEvent);
            [SVProgressHUD showSuccessWithStatus:nil];
        } else {
            Event *newEvent = [[DataManager sharedManager] createEventWithName:_nameTextField.text
                                                                     startDate:_startsDatePicker.date
                                                                       endDate:_endsDatePicker.date
                                                                       details:_descriptionTextField.text];
            
            [[DataManager sharedManager] saveContext];
            NSLog(@"Saved new event: %@", newEvent);
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
    }
    else {
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

@end
