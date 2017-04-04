//
//  EventDetailsViewController.m
//  Time Left
//
//  Created by Salavat Khanov on 1/20/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ESTBlurredStatusBar.h"

@interface EventDetailsViewController () <UIGestureRecognizerDelegate>

@property int progressViewTapCounter;
@property UIView *darkImageOverlay;
@property BOOL shownDeleteEventAlert;
@property UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet ProgressIndicator *progressView;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;


@end

@implementation EventDetailsViewController

#pragma mark - Setup View
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self setupColors];
    [self setupProgressLabels];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
    
    self.bgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self addBackgroundImage:self.event.image];
    
    //Add dark overlay so the bg image is always visible
    _darkImageOverlay = [[UIView alloc] initWithFrame:self.view.frame];
    _darkImageOverlay.backgroundColor = [UIColor blackColor];
    _darkImageOverlay.alpha = 0.5;
    [self.view insertSubview:_darkImageOverlay aboveSubview:_bgImageView];
}
- (void)askToDeleteEvent {
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM d" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    
    NSString *dateString = [formatter stringFromDate:self.event.endDate];
    
    NSString *deleteTitleLocalized = NSLocalizedString(@"Delete", nil);
    NSString *deleteMessageLocalized = NSLocalizedString(@"ended on", nil);
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@?", deleteTitleLocalized, self.event.name]
                                          message:[NSString stringWithFormat:@"%@ %@ %@.", self.event.name, deleteMessageLocalized, dateString]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Delete", nil)
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction *action)
                             {
                                 [[DataManager sharedManager] deleteEvent:self.event];
                                 [[DataManager sharedManager] saveContext];
                                 [self.navigationController popToRootViewControllerAnimated:YES];
                             }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alertController addAction:delete];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)setupColors {
    self.view.backgroundColor = [ThemeManager getBackgroundColor];
    self.progressView.progressLabel.textColor = [ThemeManager getThemeColor];
    self.progressView.metaLabel.textColor = [ThemeManager getThemeColor];
}
- (void)setupLabels {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.nameLabel.text = self.event.name;
    self.nameLabel.alpha = 1.0;
    self.progressView.alpha = 1.0;
    self.descriptionLabel.alpha = 1.0;
    
    self.descriptionLabel.text = [dateFormatter stringFromDate:self.event.startDate];
}
- (void)addBackgroundImage:(UIImage *)image {
    _bgImageView.image = image;
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bgImageView.clipsToBounds = true;
    [self.view insertSubview:_bgImageView atIndex:0];
}
- (void)setupProgressLabels {
    // Set percent for progress indicator
    self.progressView.percentInnerCircle = [self.event progress] * 100;
    
    // Set the best number and word to display
    NSDictionary *options = [self.event bestNumberAndText];
    //Remove -
    NSString *number = [options valueForKey:@"number"];
    self.progressView.progressLabel.text = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
    self.progressView.metaLabel.text = [options valueForKey:@"text"];
}
- (void)updateProgressView {
    // Redraw
    [self setupProgressLabels];
    [self.progressView setNeedsDisplay];
    
    if (self.event.isOver && !_shownDeleteEventAlert) {
        [self askToDeleteEvent];
        _shownDeleteEventAlert = true;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupLabels];
    [self updateProgressView];
    [self addBackgroundImage:self.event.image];
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
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        _bgImageView.frame = self.view.bounds;
    } completion:nil];
}
#pragma mark - Editing
- (void)editButtonPressed {
    [self performSegueWithIdentifier:@"showEditEventView" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEditEventView"]) {
        EditViewController *editController = (EditViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        editController.isEditing = true;
        editController.event = self.event;
    }
}
#pragma mark - Sharing
- (void)shareButtonPressed {
    NSString *shareAttribution = @"via Days Pro http://daysapp.pro";
    
    // prepare string
    NSString *shareString;
    if (self.event.details.length == 0) {
        shareString = [NSString stringWithFormat: @"%@ (%@) - %@", self.nameLabel.text, self.descriptionLabel.text, shareAttribution];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        shareString = [NSString stringWithFormat: @"%@ (%@): %@ - %@", self.nameLabel.text, [dateFormatter stringFromDate:self.event.endDate], self.descriptionLabel.text, shareAttribution];
    }
    
    // prepare image
    CGFloat verticalOffset = 130.0;
    UIImage *finalImage = [self cropImage:[self screenshot] byOffset:verticalOffset];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[shareString, finalImage] applicationActivities:nil];
    avc.popoverPresentationController.barButtonItem = _actionButton;
    avc.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];
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
                                      _bgImageView.image = nil;
                                  }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:nil];
    [alertController addAction:takePicture];
    [alertController addAction:cameraRoll];
    
    //Only show the remove button if there's an image
    if (self.bgImageView.image) {
        [alertController addAction:removeImage];
    }
    
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)deleteEvent:(id)sender {
    UIAlertAction *cancel = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *delete = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Delete", nil)
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action)
                                  {
                                      [[DataManager sharedManager] deleteEvent:self.event];
                                      [[DataManager sharedManager] saveContext];
                                      [self.navigationController popToRootViewControllerAnimated:YES];
                                  }];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        UIAlertController *alertControllerPad = [UIAlertController
                                                 alertControllerWithTitle:NSLocalizedString(@"Delete Event", nil)
                                                 message:nil
                                                 preferredStyle:UIAlertControllerStyleAlert];
        [alertControllerPad addAction:delete];
        [alertControllerPad addAction:cancel];
        [self presentViewController:alertControllerPad animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"Delete Event", nil)
                                              message:nil
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:delete];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (IBAction)shareEvent:(id)sender {
    [Answers logShareWithMethod:@"Share Button" contentName:self.event.name contentType:@"event" contentId:self.event.uuid customAttributes:nil];
    [self shareButtonPressed];
}
- (IBAction)editEvent:(id)sender {
    [self editButtonPressed];
}
- (UIImage *)fixOrientation:(UIImage *)image {
    // http://stackoverflow.com/a/5427890
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
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
        NSString* path = [documentsDirectory stringByAppendingPathComponent:self.event.uuid];
        NSData* data = UIImagePNGRepresentation([self fixOrientation:image]);
        [data writeToFile:path atomically:YES];
        [self addBackgroundImage:image];
    }
}


@end
