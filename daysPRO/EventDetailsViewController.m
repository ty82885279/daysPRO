//
//  EventDetailsViewController.m
//  Time Left
//
//  Created by Salavat Khanov on 1/20/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "AppDelegate.h"
#import "AddEventTableViewController.h"

static NSString *kEventDetailsScreenName = @"Event Details";

@interface EventDetailsViewController () <UIGestureRecognizerDelegate> {
    UIImageView *bgImageView;
}

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet ProgressIndicator *progressView;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger tapCounter;
@property (assign, nonatomic, getter = isShouldBeHidingStatusBar) BOOL shouldBeHidingStatusBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender;


@end

@implementation EventDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - Setup View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self setupColors];
    [self setupProgressLabels];
    [self setupNavigationButtons];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
    self.tapCounter = 0;
}

- (void)askToDeleteEvent {
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM d" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    
    NSString *dateString = [formatter stringFromDate:self.event.endDate];
    
    if (self.event.endDate < [NSDate date]) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:[NSString stringWithFormat:@"Delete %@?", self.event.name]
                                              message:[NSString stringWithFormat:@"%@ ended on %@.", self.event.name, dateString]
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *delete = [UIAlertAction
                                       actionWithTitle:@"Delete"
                                       style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *action)
                                       {
                                           [[DataManager sharedManager] deleteEvent:self.event];
                                           [[DataManager sharedManager] saveContext];
                                           [self.navigationController popToRootViewControllerAnimated:YES];
                                       }];
        
        UIAlertAction *cancel = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
        
        [alertController addAction:delete];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (void)setupColors {
    ThemeManager *themeManager = [[ThemeManager alloc] init];
    NSDictionary *colors = [themeManager getTheme];
    self.view.backgroundColor = [colors objectForKey:@"background"];
    // Transparent nav bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.nameLabel.textColor = [colors objectForKey:@"colorText"];
    self.descriptionLabel.textColor = [colors objectForKey:@"colorText"];
}

- (void)setupLabels {
    [self askToDeleteEvent];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.nameLabel.text = self.event.name;
    [UIView animateWithDuration:0.5 animations:^{
        self.nameLabel.alpha = 1.0;
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.progressView.alpha = 1.0;
    }];
    
    [UIView animateWithDuration:0.6 animations:^{
        self.descriptionLabel.alpha = 0.0;
    }];
    
    if ([self.event progress] < 0) {
        /*
         * Event not yet started
         * Cases:
         * 1) Starts Date
         * 2) Description (if available)
         * 3) Ends Date
         */
        switch (self.tapCounter % 3) {
            case 0:
                self.descriptionLabel.text = [NSString stringWithFormat:@"Starts on %@", [dateFormatter stringFromDate:self.event.startDate]];
                break;
            case 1:
                if (self.event.details.length) {
                    self.descriptionLabel.text = self.event.details;
                    break;
                } else {
                    self.tapCounter++;
                }
            default:
                self.descriptionLabel.text = [NSString stringWithFormat:@"Ends on %@", [dateFormatter stringFromDate:self.event.endDate]];
                break;
        }
        
    } else if ([self.event progress] >= 0 && [self.event progress] <= 1.0) {
        /*
         * Event in-progress
         * Cases:
         * 1) Description (if available)
         * 2) Ends Date
         */
        switch (self.tapCounter % 2) {
            case 0:
                if (self.event.details.length) {
                    self.descriptionLabel.text = self.event.details;
                    break;
                } else {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Ends on %@", [dateFormatter stringFromDate:self.event.endDate]];
                    break;
                }
            default:
                if (self.event.details.length) {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Ends on %@", [dateFormatter stringFromDate:self.event.endDate]];
                    break;
                } else {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Started on %@", [dateFormatter stringFromDate:self.event.startDate]];
                    break;
                }
        }
        
    } else if ([self.event progress] > 1.0) {
        /*
         * Event done
         * Cases:
         * 1) Description (if available)
         * 2) Ended Date
         */
        switch (self.tapCounter % 2) {
            case 0:
                if (self.event.details.length) {
                    self.descriptionLabel.text = self.event.details;
                    break;
                } else {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Ended on %@", [dateFormatter stringFromDate:self.event.endDate]];
                    break;
                }
            default:
                if (self.event.details.length) {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Ended on %@", [dateFormatter stringFromDate:self.event.endDate]];
                    break;
                } else {
                    self.descriptionLabel.text = [NSString stringWithFormat:@"Started on %@", [dateFormatter stringFromDate:self.event.startDate]];
                    break;
                }
        }
    }
    
    // Animate fade-in
    [UIView animateWithDuration:0.6 animations:^{
        self.descriptionLabel.alpha =  0.65;
    }];
    [self addBackgroundImage];
}
- (void)addBackgroundImage {
    bgImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    bgImageView.image = [self loadImage];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.clipsToBounds = true;
    [self.view insertSubview:bgImageView atIndex:0];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    
    visualEffectView.frame = self.view.bounds;
    [self.view insertSubview:visualEffectView atIndex:1];
}
- (UIImage *)loadImage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:self.event.uuid];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}
- (void)setupNavigationButtons {
    CGSize barButtonSize = CGSizeMake(40.0f, 40.0f);
    
    // Back button
    UIImage *backButtonImage = [UIImage imageNamed:@"back-icon"];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.backgroundColor = [UIColor clearColor];
    backButton.frame = CGRectMake(-2, 0, barButtonSize.width, barButtonSize.height);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    backButton.tintColor = [UIColor colorWithRed:241.0/255.0 green:176.0/255.0 blue:51.0/255.0 alpha:1.0];
    backButton.autoresizesSubviews = YES;
    backButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    self.navigationController.navigationBar.backIndicatorImage = backButtonImage;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backButtonImage;
}

- (void)setupProgressLabels {
    // Set percent for progress indicator
    self.progressView.percentInnerCircle = [self.event progress] * 100;
    
    // Set the best number and word to display
    NSDictionary *options = [self.event bestNumberAndText];
    self.progressView.progressLabel.text = [options valueForKey:@"number"];
    self.progressView.metaLabel.text = [options valueForKey:@"text"];
}

- (void)updateProgressView {
    // Redraw
    [self setupProgressLabels];
    [self.progressView setNeedsDisplay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupLabels];
    [self updateProgressView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    self.tapCounter++;
    [self setupLabels];
}


#pragma mark - Editing

- (void)editButtonPressed {
    [self performSegueWithIdentifier:@"showEditEventView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEditEventView"]) {
        AddEventTableViewController *editEventViewController = (AddEventTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        editEventViewController.eventEditMode = YES;
        editEventViewController.event = _event;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIPopoverController *popover = [(UIStoryboardPopoverSegue *)segue popoverController];
            ThemeManager *themeManager = [[ThemeManager alloc] init];
            NSDictionary *colors = [themeManager getTheme];
            popover.backgroundColor = [colors objectForKey:@"background"];
            
            editEventViewController.popover = popover;
        }
    }
}


#pragma mark - Sharing

- (void)shareButtonPressed {
    // prepare string
    NSString *shareString;
    if (self.event.details.length == 0) {
        shareString = [NSString stringWithFormat: @"%@ (%@)", self.nameLabel.text, self.descriptionLabel.text];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        shareString = [NSString stringWithFormat: @"%@ (%@): %@", self.nameLabel.text, [dateFormatter stringFromDate:self.event.endDate], self.descriptionLabel.text];
    }
    
    // prepare image
    CGFloat verticalOffset = 130.0;
    UIImage *finalImage = [self cropImage:[self screenshot] byOffset:verticalOffset];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[shareString, finalImage] applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop];
    [self presentViewController:avc animated:YES completion:NULL];
}

#pragma mark — Screenshot

- (UIImage *)screenshot {
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)cropImage:(UIImage *)image byOffset:(CGFloat) verticalOffset {
    CGRect cropRect = CGRectMake(0, verticalOffset, image.size.width * 2.0, image.size.height * 2.0 - verticalOffset);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}
- (IBAction)selectImageToEvent:(id)sender {
    UIImagePickerController *picker;
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = true;
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Add Image"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *takePicture = [UIAlertAction
                                  actionWithTitle:@"Take a Picture"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                      [self presentViewController:picker animated:YES completion:nil];
                                  }];
    
    UIAlertAction *cameraRoll = [UIAlertAction
                                 actionWithTitle:@"Select Image"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                     [self presentViewController:picker animated:YES completion:^{
                                         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
                                         picker.topViewController.title = @"Select Image";
                                         picker.navigationBar.translucent = NO;
                                         picker.navigationBar.barStyle = UIBarStyleDefault;
                                         [picker setNavigationBarHidden:NO animated:NO];
                                     }];
                                 }];
    
    UIAlertAction *removeImage = [UIAlertAction
                                  actionWithTitle:@"Remove Image"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      //remove the image
                                      NSFileManager *fileManager = [NSFileManager defaultManager];
                                      NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                                      
                                      NSString *filePath = [documentsPath stringByAppendingPathComponent:self.event.uuid];
                                      NSError *error;
                                      [fileManager removeItemAtPath:filePath error:&error];
                                      bgImageView.image = nil;
                                  }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:nil];
    [alertController addAction:takePicture];
    [alertController addAction:cameraRoll];
    //Only show the remove button if there's an image
    if (bgImageView.image) {
        [alertController addAction:removeImage];
    }
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)deleteEvent:(id)sender {
    [[DataManager sharedManager] deleteEvent:self.event];
    [[DataManager sharedManager] saveContext];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)shareEvent:(id)sender {
    [Answers logCustomEventWithName:@"Share event" customAttributes:@{@"Name":self.event.name}];
    [self shareButtonPressed];
}
- (IBAction)editEvent:(id)sender {
    [self editButtonPressed];
}


#pragma mark - ImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self saveImage:image];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage: (UIImage *)image {
    if (image != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:self.event.uuid];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
        [self viewDidLoad]; [self viewWillAppear:YES];
    }
}


@end
