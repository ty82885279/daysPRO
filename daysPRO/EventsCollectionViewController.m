//
//  EventsCollectionViewController.m
//  Time Left
//
//  Created by Salavat Khanov on 1/23/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "EventsCollectionViewController.h"
#import "EventCell.h"
#import "EventDetailsViewController.h"
#import "CustomCollectionViewFlowLayout.h"
#import "AddEventTableViewController.h"
#import "AppDelegate.h"
#import "ESTBlurredStatusBar.h"

static NSInteger kMarginTopBottomiPhone = 12;
static NSInteger kMarginTopBottomiPad = 30;
static NSInteger kMarginLeftRightiPhone = 10;
static NSInteger kMarginLeftRightiPad = 10;

static CGFloat kCollectionViewContentOffsetiPhone = -64.0f;

static NSInteger kCellWeightHeightiPhone = 145;
static NSInteger kCellWeightHeightiPad = 242;

@interface EventsCollectionViewController ()

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic,strong) NSMutableArray *fetchedEventsArray;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property (assign, nonatomic) BOOL shouldBeHidingStatusBar;
@property (assign, nonatomic) BOOL shouldBeHidingAddButton;
@property (strong, nonatomic) UIDynamicAnimator *animator;

- (IBAction)deleteButton:(UIButton *)sender;

@end

@implementation EventsCollectionViewController

static GADBannerView *bannerView;
static UIView *senderView;
static UIView *containerView;
static UIView *bannerContainerView;
static float bannerHeight;
int shakeCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - Configure View

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupColors];
    [self registerForNotifications];
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    
    // Allocate and configure the layout
    CustomCollectionViewFlowLayout *layout = [[CustomCollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 10.f;
    layout.minimumLineSpacing = 10.f;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
    self.collectionView.collectionViewLayout = layout;
    
    // Motion effects
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = @-20;
    xAxis.maximumRelativeValue = @20;
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = @-20;
    yAxis.maximumRelativeValue = @20;
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis, yAxis];
    [self.collectionView addMotionEffect:group];
    
    // Set navigation bar font
    UIFont *backButtonFont = [UIFont systemFontOfSize:17.0f];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName : backButtonFont} forState:UIControlStateNormal];
    
    // Long press gesture recognizer
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5; //seconds
    longPressGestureRecognizer.delegate = self;
    longPressGestureRecognizer.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
    
    // Tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:tapGestureRecognizer];
    
    //Blurred status bar
    ESTBlurredStatusBar *blurredStatusBar = [[ESTBlurredStatusBar alloc] initWithStyle:UIBlurEffectStyleDark];
    [self.view insertSubview:blurredStatusBar atIndex:10];
}

- (void)setupColors {
    ThemeManager *themeManager = [[ThemeManager alloc] init];
    NSDictionary *colors = [themeManager getTheme];
    self.view.backgroundColor = [colors objectForKey:@"background"];
    self.collectionView.backgroundColor = [colors objectForKey:@"background"];
    // Transparent nav bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    // Light status bar
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}


#pragma mark Notifications

- (void)registerForNotifications {
    // Model Changed Notification: event added
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventAdded:)
                                                 name:@"EventAdded"
                                               object:nil];
    
    // Stop edit mode after loosing focus
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResign)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)eventAdded:(NSNotification *)addedNotification {
    if ([[addedNotification.userInfo allKeys][0] isEqual:@"added"]) {
        Event *eventToAdd = [addedNotification.userInfo objectForKey:@"added"];
        self.fetchedEventsArray = [NSMutableArray arrayWithArray:[[DataManager sharedManager] getAllEvents]];
        NSInteger index = [self.fetchedEventsArray indexOfObject:eventToAdd];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    }
}

- (void)applicationWillResign {
    [self doneEditing];
}


#pragma mark Update View

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self doneEditing]; // if needed
    [self updateView];
    [self startTimer];
    
    // Fix strange case, when there's extra content offset added after returning from event detail view
    CGPoint offset = self.collectionView.contentOffset;
    if (offset.y < kCollectionViewContentOffsetiPhone) {
        offset.y = kCollectionViewContentOffsetiPhone;
        self.collectionView.contentOffset = offset;
    }
    shakeCount = 0;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableAds"]) {
        [self createBanner:self];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopTimer];
}

- (void)startTimer {
    if ([self.fetchedEventsArray count] && self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateView) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)updateView {
    self.fetchedEventsArray = [NSMutableArray arrayWithArray:[[DataManager sharedManager] getAllEvents]];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Ads
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake) {
        if (shakeCount < 3) {
            shakeCount++;
        } else {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:NSLocalizedString(@"Disable Ads", nil)
                                                  message:NSLocalizedString(@"Do you want to disable ads? You can't enable them later.", nil)
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *disableAds = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Disable Ads", nil)
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"disableAds"];
                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                           [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Closing in 3 seconds...", nil)];
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                               exit(0);
                                           });
                                       }];
            
            [alertController addAction:disableAds];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)createBanner:(UIViewController *)sender {
     //http://stackoverflow.com/questions/21760071/add-gadbannerview-programmatically
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        bannerHeight = 50;
    } else {
        bannerHeight = 90;
    }
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[@"46f9b28f18fe07b396aaf642aef67a21"];
    
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView.adUnitID = @"ca-app-pub-2929799728547191/2681319469";
    bannerView.rootViewController = (id)self;
    bannerView.delegate = (id<GADBannerViewDelegate>)self;
    
    senderView = sender.view;
    
    bannerView.frame = CGRectMake(0, 0, senderView.frame.size.width, bannerHeight);
    
    [bannerView loadRequest:request];
    
    containerView = [[UIView alloc] initWithFrame:senderView.frame];
    
    bannerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, senderView.frame.size.height, senderView.frame.size.width, bannerHeight)];
    
    for (id object in sender.view.subviews) {
        
        [object removeFromSuperview];
        [containerView addSubview:object];
        
    }
    
    [senderView addSubview:containerView];
    [senderView insertSubview:bannerContainerView aboveSubview:self.collectionView];
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    [UIView animateWithDuration:0.5 animations:^{
        
        self.collectionView.frame = CGRectMake(0, 0, senderView.frame.size.width, senderView.frame.size.height - bannerHeight);
        bannerContainerView.frame = CGRectMake(0, senderView.frame.size.height - bannerHeight, senderView.frame.size.width, bannerHeight);
        [bannerContainerView addSubview:bannerView];
        
    }];
}
#pragma mark - Status Bar Appearance

- (BOOL)prefersStatusBarHidden {
    return self.shouldBeHidingStatusBar;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)hideStatusBar {
    if (self.shouldBeHidingStatusBar == NO) {
        self.shouldBeHidingStatusBar = YES;
        [UIView animateWithDuration:0.1 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
}

- (void)showStatusBar {
    if (self.shouldBeHidingStatusBar) {
        self.shouldBeHidingStatusBar = NO;
        [UIView animateWithDuration:0.1 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.fetchedEventsArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"EventCell" forIndexPath:indexPath];
    
    Event *event = self.fetchedEventsArray[indexPath.row];
    cell.name.text = event.name;
    cell.progressView.percentCircle = [event progress] * 100;
    
    self.isEditing ? [cell startQuivering] : [cell stopQuivering];
    
    NSDictionary *options = [event bestNumberAndText];
    //Remove -
    NSString *number = [options valueForKey:@"number"];
    cell.progressView.progressLabel.text = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
    cell.progressView.metaLabel.text = [options valueForKey:@"text"];
    
    // for events that have finished, use special font to display symbol
    [event progress] > 1.0 ? [cell.progressView useFontForSymbol] : [cell.progressView useDefaultFont];
    // for events that haven't yet started, use smaller text
    [event progress] < 0 ? [cell.progressView useSmallerFont] : [cell.progressView useDefaultFont];
    
    [cell.progressView setNeedsDisplay];
    
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return CGSizeMake(kCellWeightHeightiPhone, kCellWeightHeightiPhone);
    } else {
        return CGSizeMake(kCellWeightHeightiPad, kCellWeightHeightiPad);
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIEdgeInsetsMake(kMarginTopBottomiPhone, kMarginLeftRightiPhone, kMarginTopBottomiPhone, kMarginLeftRightiPhone);
    } else {
        return UIEdgeInsetsMake(kMarginTopBottomiPad, kMarginLeftRightiPad, kMarginTopBottomiPad, kMarginLeftRightiPad);
    }
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showEventDetailsView"] && self.editing) {
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass the selected event to the details view controller.
    if ([segue.identifier isEqualToString:@"showEventDetailsView"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        EventDetailsViewController *eventDetailsViewController = segue.destinationViewController;
        eventDetailsViewController.event = [self.fetchedEventsArray objectAtIndex:indexPath.row];
        [Answers logCustomEventWithName:@"Open event" customAttributes:@{@"Name":eventDetailsViewController.event.name}];
    } else if ([segue.identifier isEqualToString:@"showAddEventView"] && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [(UIStoryboardPopoverSegue *)segue popoverController];
        ThemeManager *themeManager = [[ThemeManager alloc] init];
        NSDictionary *colors = [themeManager getTheme];
        popover.backgroundColor = [colors objectForKey:@"background"];
        AddEventTableViewController *addEventController = (AddEventTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        addEventController.popover = popover;
    }
}

- (void)showAddEventView {
    [self performSegueWithIdentifier:@"showAddEventView" sender:nil];
}


#pragma mark - Edit mode

- (void)longPressGesture:(UIGestureRecognizer *)recognizer {
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        
        UICollectionViewCell *cellAtTapPoint = [self collectionViewCellForTapAtPoint:[recognizer locationInView:self.collectionView]];
        
        // If there's cell, where long tap was performed, start editing mode
        if (cellAtTapPoint && !self.editing) {
            // Replace Add button to Done in the navbar
            UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
            [self.navigationItem setRightBarButtonItem:done];
            // Start Editing mode
            self.editing = YES;
            [self stopTimer];
            [self updateView];
        }
        else {
            [self doneEditing];
        }
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        
        UICollectionViewCell *cellAtTapPoint = [self collectionViewCellForTapAtPoint:[recognizer locationInView:self.collectionView]];
        
        // If there's no cell, where tap was performed, and editing mode is ON, then stop editing mode
        if (!cellAtTapPoint && self.editing) {
            [self doneEditing];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer class] == [UITapGestureRecognizer class] && ![self collectionViewCellForTapAtPoint:[touch locationInView:self.collectionView]]) {
        return YES;
    }
    
    if ([gestureRecognizer class] == [UILongPressGestureRecognizer class]) {
        return YES;
    }
    
    return NO;
}

- (UICollectionViewCell *)collectionViewCellForTapAtPoint:(CGPoint)tapPoint {
    NSIndexPath *indexPathForTapPoint = [self.collectionView indexPathForItemAtPoint:tapPoint];
    return [self.collectionView cellForItemAtIndexPath:indexPathForTapPoint];
}

- (IBAction)deleteButton:(UIButton *)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(EventCell *)sender.superview.superview];
    [[DataManager sharedManager] deleteEvent:self.fetchedEventsArray[indexPath.row]];
    [[DataManager sharedManager] saveContext];
    self.fetchedEventsArray = [NSMutableArray arrayWithArray:[[DataManager sharedManager] getAllEvents]];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

- (void)doneEditing {
    if (self.isEditing) {
        // Replace Add button to Done
        [self.navigationItem setRightBarButtonItem:self.addBarButtonItem];
        // Stop Edit mode
        self.editing = NO;
        [self startTimer];
        [self updateView];
    }
}
- (IBAction)add:(id)sender {
    [self showAddEventView];
}

#pragma mark - Empty
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    if ([[[ThemeManager alloc] init] isDecember]) {
        return [UIImage imageNamed:@"placeholder-December"];
    }
    return [UIImage imageNamed:@"placeholder"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"No Events", nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor lightTextColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f],
                                 NSForegroundColorAttributeName: [[[ThemeManager alloc] init] getTextColor]};
    
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"New Event", nil) attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self showAddEventView];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return kCollectionViewContentOffsetiPhone;
}

@end
