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

#pragma mark - Configure View
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Events", nil);
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
}
- (void)setupColors {
    self.view.backgroundColor = [ThemeManager getBackgroundColor];
    self.collectionView.backgroundColor = [ThemeManager getBackgroundColor];
    if ([ThemeManager darkMode]) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
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
    int index = 0;
    
    NSMutableArray *shortcutItems = [[NSMutableArray alloc] init];
    NSArray *firstFour = [self.fetchedEventsArray subarrayWithRange:NSMakeRange(0, MIN(4, self.fetchedEventsArray.count))];

    for (Event *event in firstFour) {
        NSDictionary *options = [event bestNumberAndText];
        NSString *number = [[options valueForKey:@"number"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *text = [options valueForKey:@"text"];
        UIApplicationShortcutItem *eventItem = [[UIApplicationShortcutItem alloc]initWithType:[NSString stringWithFormat:@"%d", index] localizedTitle:event.name localizedSubtitle:[NSString stringWithFormat:@"%@ %@", number, text] icon:nil userInfo:nil];
        [shortcutItems addObject:eventItem];
        index++;
    }
    
    [UIApplication sharedApplication].shortcutItems = shortcutItems;
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
                                 NSForegroundColorAttributeName: [ThemeManager getThemeColor]};
    
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"New Event", nil) attributes:attributes];
}
- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self showAddEventView];
}
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return kCollectionViewContentOffsetiPhone;
}

@end
