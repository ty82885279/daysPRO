//
//  EditViewController.m
//  Days Pro
//
//  Created by Oliver Kulpakko on 2017-01-15.
//  Copyright © 2017 East Studios. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.isEditing) {
        self.title = self.event.name;
        self.datePicker.date = self.event.startDate;
        self.nameTextField.text = self.event.name;
    } else {
        self.datePicker.minimumDate = [NSDate date];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    [self.view addGestureRecognizer:tap];
    
    self.eventImageView.image = self.event.image;
    self.eventImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.eventImageView.clipsToBounds = true;

    [self.navigationController.navigationBar setTitleTextAttributes:
    @{NSForegroundColorAttributeName:[ThemeManager getThemeColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboards {
    [self.nameTextField resignFirstResponder];
}

- (IBAction)saveEvent:(id)sender {
    if (self.nameTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No Name", nil)];
    } else {
        NSDate *date = [self dateWithHour:0 minute:0 second:0 date:self.datePicker.date];
        if (self.isEditing) {
            [[DataManager sharedManager] updateEvent:self.event withName:self.nameTextField.text
                                           startDate:date endDate:date details:nil image:self.eventImageView.image];
            [[DataManager sharedManager] saveContext];
            
            [Answers logCustomEventWithName:@"Edit event" customAttributes:@{@"Name":_nameTextField.text}];
        } else {
            [[DataManager sharedManager] createEventWithName:self.nameTextField.text
                                                   startDate:date endDate:date details:nil image:self.eventImageView.image];
            
            [[DataManager sharedManager] saveContext];
            [Answers logCustomEventWithName:@"Add event" customAttributes:@{@"Name":_nameTextField.text}];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showSuccessWithStatus:nil];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeImage:(id)sender {
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
                                      self.eventImageView.image = nil;
                                  }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:nil];
    [alertController addAction:takePicture];
    [alertController addAction:cameraRoll];
    
    //Only show the remove button if there's an image
    if (self.eventImageView.image) {
        [alertController addAction:removeImage];
    }
    
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(NSDate *)dateWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second date:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:
                                    NSCalendarUnitYear| NSCalendarUnitMonth| NSCalendarUnitDay fromDate:date];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    NSDate *newDate = [calendar dateFromComponents:components];
    return newDate;
}

#pragma mark - ImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.eventImageView.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
