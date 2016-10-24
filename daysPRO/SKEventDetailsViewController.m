//
//  SKEventDetailsViewController.m
//  Time Left
//
//  Created by Salavat Khanov on 1/20/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "SKEventDetailsViewController.h"
#import "SKAppDelegate.h"
#import "SKAddEventTableViewController.h"

static NSString *kEventDetailsScreenName = @"Event Details";

@interface SKEventDetailsViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet SKProgressIndicator *progressView;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger tapCounter;
@property (assign, nonatomic, getter = isShouldBeHidingStatusBar) BOOL shouldBeHidingStatusBar;

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender;


@end

@implementation SKEventDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

#pragma mark - Setup View

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self setupColors];
    [self setupProgressLabels];
    [self setupNavigationButtons];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
    self.tapCounter = 0;
}

- (void)setupColors
{
    SKAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSDictionary *colors = [delegate currentTheme];
    self.view.backgroundColor = [colors objectForKey:@"background"];
    // Transparent nav bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.nameLabel.textColor = [colors objectForKey:@"colorText"];
    self.descriptionLabel.textColor = [colors objectForKey:@"colorText"];
}

- (void)setupLabels
{
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
}

- (void)setupNavigationButtons
{
    CGSize barButtonSize = CGSizeMake(35.0f, 35.0f);
    UIView *rightButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barButtonSize.width * 3 + 15, barButtonSize.height)];
    
    // Edit button
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    editButton.backgroundColor = [UIColor clearColor];
    editButton.frame = CGRectMake(barButtonSize.width + 10, 0, barButtonSize.width, barButtonSize.height);
    [editButton setImage:[UIImage imageNamed:@"settings-icon"] forState:UIControlStateNormal];
    editButton.tintColor = [UIColor whiteColor];
    editButton.autoresizesSubviews = YES;
    editButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonsView addSubview:editButton];
    
    // Share button
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    shareButton.backgroundColor = [UIColor clearColor];
    shareButton.frame = CGRectMake(editButton.frame.origin.x + barButtonSize.width + 5, 0, barButtonSize.width, barButtonSize.height);
    [shareButton setImage:[UIImage imageNamed:@"share-icon"] forState:UIControlStateNormal];
    shareButton.tintColor = [UIColor whiteColor];
    shareButton.autoresizesSubviews = YES;
    shareButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [rightButtonsView addSubview:shareButton];
    
    _rightBarButton.customView = rightButtonsView;
    self.navigationItem.rightBarButtonItem = _rightBarButton;
    
    // Back button
    UIImage *backButtonImage = [UIImage imageNamed:@"back-icon"];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.backgroundColor = [UIColor clearColor];
    backButton.frame = CGRectMake(-2, 0, barButtonSize.width, barButtonSize.height);
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    backButton.tintColor = [UIColor whiteColor];
    backButton.autoresizesSubviews = YES;
    backButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    self.navigationController.navigationBar.backIndicatorImage = backButtonImage;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backButtonImage;
}

- (void)setupProgressLabels
{
    // Set percent for progress indicator
    self.progressView.percentInnerCircle = [self.event progress] * 100;
    
    // Set the best number and word to display
    NSDictionary *options = [self.event bestNumberAndText];
    self.progressView.progressLabel.text = [options valueForKey:@"number"];
    self.progressView.metaLabel.text = [options valueForKey:@"text"];
}

- (void)updateProgressView
{
    // Redraw
    [self setupProgressLabels];
    [self.progressView setNeedsDisplay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupLabels];
    [self updateProgressView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender
{
    self.tapCounter++;
    [self setupLabels];
}


#pragma mark - Editing

- (void)editButtonPressed
{
    [self performSegueWithIdentifier:@"showEditEventView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showEditEventView"]) {
        SKAddEventTableViewController *editEventViewController = (SKAddEventTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        editEventViewController.eventEditMode = YES;
        editEventViewController.event = _event;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIPopoverController *popover = [(UIStoryboardPopoverSegue *)segue popoverController];
            SKAppDelegate *delegate = [UIApplication sharedApplication].delegate;
            NSDictionary *colors = [delegate currentTheme];
            popover.backgroundColor = [colors objectForKey:@"background"];

            editEventViewController.popover = popover;
        }
    }
}


#pragma mark - Sharing

- (void)shareButtonPressed
{
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

- (UIImage *)screenshot
{
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

- (UIImage *)cropImage:(UIImage *)image byOffset:(CGFloat) verticalOffset
{
    CGRect cropRect = CGRectMake(0, verticalOffset, image.size.width * 2.0, image.size.height * 2.0 - verticalOffset);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}


@end
