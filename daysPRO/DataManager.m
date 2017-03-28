//
//  DataManager.m
//  Time Left
//
//  Created by Salavat Khanov on 1/25/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import "DataManager.h"

static NSString *kModelName = @"AppModel";
static NSString *kSQLName = @"TimeLeft.sqlite";
static NSString *kEventEntityName = @"Event";

NSString *const kEventAddedNotificationName = @"EventAdded";
NSString *const kEventUpdatedNotificationName = @"EventUpdated";
NSString *const kEventDeletedNotificationName = @"EventDeleted";

NSString *const kAddedKey = @"added";
NSString *const kUpdatedKey = @"updated";
NSString *const kDeletedKey = @"deleted";


@interface DataManager ()
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end


@implementation DataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (DataManager *)sharedManager {
    static dispatch_once_t once;
    static DataManager *sharedManager;
    
    dispatch_once(&once, ^{
        sharedManager = [[DataManager alloc] init];
    });
    
    return sharedManager;
}
#pragma mark - Core Data stack
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *psc = [self persistentStoreCoordinator];
    
    if (psc) {
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: psc];
        }];
        
        NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
        [dc addObserver:self
               selector:@selector(objectContextDidSave:)
                   name:NSManagedObjectContextDidSaveNotification
                 object:_managedObjectContext];
        
        _managedObjectContext = moc;
    } else {
        [SVProgressHUD showErrorWithStatus:@"Error while creating coordinator"];
    }
    
    return _managedObjectContext;
}
/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kModelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}
/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(storesWillChange:)
               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
             object:_persistentStoreCoordinator];
    
    [dc addObserver:self
           selector:@selector(storesDidChange:)
               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
             object:_persistentStoreCoordinator];
    
    [dc addObserver:self
           selector:@selector(persistentStoreDidImportUbiquitiousContentChanges:)
               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object:_persistentStoreCoordinator];
    
    [self addPersistentStoreToCoordinator];
    
    return _persistentStoreCoordinator;
}
#pragma mark - Adding persistent stores
- (void)addPersistentStoreToCoordinator {
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:@YES forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:@YES forKey:NSInferMappingModelAutomaticallyOption];
    
    NSURL *iCloud = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier: nil];
    
    if (iCloud) {
        [options setObject:@"iCloud.com.eaststudios.dayspronew" forKey:NSPersistentStoreUbiquitousContentNameKey];
    }
    
    NSURL *documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                       inDomain:NSUserDomainMask
                                                              appropriateForURL:nil
                                                                         create:YES
                                                                          error:NULL];
    
    NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:kSQLName];
    
    NSError *error;
    
    // the only difference in this call that makes the store an iCloud enabled store
    // is the NSPersistentStoreUbiquitousContentNameKey in options.
    
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:storeURL
                                                    options:options
                                                      error:&error];
    if (error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}
#pragma mark - Save Context
- (void)saveTheContext:(NSManagedObjectContext *)theContext {
    if ([self.persistentStoreCoordinator.persistentStores count] != 0) {
        
        NSError *error = nil;
        [theContext save:&error];
        if (error) {
            NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if (detailedErrors != nil && [detailedErrors count] > 0) {
                for (NSError *detailedError in detailedErrors) {
                    [SVProgressHUD showErrorWithStatus:[detailedError userInfo].description];
                }
            } else {
                [SVProgressHUD showErrorWithStatus:error.userInfo.description];
            }
        }
    }
}
- (void)saveContext {
    [self saveTheContext:self.managedObjectContext];
}
#pragma mark - Events
- (NSArray *)getAllEvents {
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEventEntityName
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedEvents = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Sort events in ascending order
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:YES];
    
    // Return Sorted Fetched Events
    return [fetchedEvents sortedArrayUsingDescriptors:@[sortDescriptor]];
}
- (Event *)createEventWithName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate details:(NSString *)details image:(UIImage *)image {
    Event *newEvent = (Event *)[NSEntityDescription insertNewObjectForEntityForName:kEventEntityName inManagedObjectContext:self.managedObjectContext];
    newEvent.name = name;
    newEvent.details = details;
    newEvent.startDate = startDate;
    newEvent.endDate = endDate;
    newEvent.createdDate = [NSDate date];
    newEvent.uuid = [[NSUUID UUID] UUIDString];
    if (image) {
        [self saveImage:image event:newEvent];
    }
    return newEvent;
}
- (void)saveImage:(UIImage *)image event:(Event *)event {
    if (image != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:event.uuid];
        NSData *data = UIImagePNGRepresentation([self fixOrientation:image]);
        [data writeToFile:path atomically:YES];
    }
}
- (Event *)updateEvent:(Event *)event withName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate details:(NSString *)details image:(UIImage *)image {
    event.name = name;
    event.startDate = startDate;
    event.endDate = endDate;
    event.details = details;
    if (image) {
        [self saveImage:image event:event];
    }
    return event;
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
- (void)deleteEvent:(Event *)event {
    [Answers logCustomEventWithName:@"Delete event" customAttributes:@{@"Name":event.name}];
    //remove the image
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:event.uuid];
    NSError *error;
    [fileManager removeItemAtPath:filePath error:&error];
    
    [self.managedObjectContext deleteObject:event];
}
- (void)addEventsFromServer {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", nil)];
    NSURL *url = [NSURL URLWithString:@"https://eaststudios.fi/api/days/v1/defaultEvents.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data
                                                            options:kNilOptions
                                                              error:&error];
            
            for (Event *record in json) {
                
                NSString *uniqueServerEventID = [record valueForKey:@"useID"];
                NSString *name = [record valueForKey:@"name"];
                NSString *details = [record valueForKey:@"description"];
                NSString *startDateString = [record valueForKey:@"startDate"];
                NSString *endDateString = [record valueForKey:@"endDate"];
                NSString *imageUrl = [record valueForKey:@"imageUrl"];
                
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[startDateString intValue]];
                NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[endDateString intValue]];
                
                NSDate *localStartDate = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:startDate];
                NSDate *localEndDate = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:endDate];
                
                if (![[NSUserDefaults standardUserDefaults] valueForKey:uniqueServerEventID]) {
                    [self createEventWithName:name
                                    startDate:localStartDate
                                      endDate:localEndDate
                                      details:details
                                        image:[self getImageFromURL:imageUrl]];
                    [self saveContext];
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:uniqueServerEventID];
                }
            }
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD showErrorWithStatus:connectionError.localizedDescription];
        }
    }];
}
-(UIImage *)getImageFromURL:(NSString *)fileURL {
    UIImage *image;
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    if (data) {
        image = [UIImage imageWithData:data];
    } else {
        image = [[UIImage alloc] init];
    }
    
    return image;
}
- (void)deleteAllEvents {
    NSFetchRequest *allEvents = [[NSFetchRequest alloc] init];
    [allEvents setEntity:[NSEntityDescription entityForName:kEventEntityName inManagedObjectContext:self.managedObjectContext]];
    [allEvents setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *events = [self.managedObjectContext executeFetchRequest:allEvents error:&error];
    
    for (NSManagedObject * event in events) {
        [self.managedObjectContext deleteObject:event];
    }
}
- (long)getNextYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year] + 1;
}
#pragma mark - iCloud notifications
- (void)persistentStoreDidImportUbiquitiousContentChanges:(NSNotification *)changeNotification {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Syncing...", nil)];
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:changeNotification];
        [self objectContextDidSaveFromiCloud:changeNotification];
        [SVProgressHUD showSuccessWithStatus:nil];
    }];
}
- (void)storesWillChange:(NSNotification *)n {
    NSManagedObjectContext *moc = [self managedObjectContext];
    [moc performBlockAndWait:^{
        NSError *error = nil;
        if ([moc hasChanges]) {
            [moc save:&error];
        }
        
        [moc reset];
    }];
}
- (void)storesDidChange:(NSNotification *)n {
}
#pragma mark - Model notifications
- (void)objectContextDidSave:(NSNotification *)notification {
    // Event inserted
    if ([notification.userInfo objectForKey:NSInsertedObjectsKey]) {
        for (id object in [notification.userInfo objectForKey:NSInsertedObjectsKey]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotificationName
                                                                object:self
                                                              userInfo:@{kAddedKey: object}];
        }
    }
    // Event updated
    if ([notification.userInfo objectForKey:NSUpdatedObjectsKey]) {
        for (id object in [notification.userInfo objectForKey:NSUpdatedObjectsKey]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kEventUpdatedNotificationName
                                                                object:self
                                                              userInfo:@{kUpdatedKey: object}];
        }
    }
    // Event deleted
    if ([notification.userInfo objectForKey:NSDeletedObjectsKey]) {
        for (id object in [notification.userInfo objectForKey:NSDeletedObjectsKey]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kEventDeletedNotificationName
                                                                object:self
                                                              userInfo:@{kDeletedKey: object}];
        }
    }
    
}
- (void)objectContextDidSaveFromiCloud:(NSNotification *)notification {
    // Event inserted
    NSDictionary *insertedObjectIDs = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    if (insertedObjectIDs) {
        for (NSManagedObjectID *objID in insertedObjectIDs) {
            NSError *error = nil;
            NSManagedObject *object = [self.managedObjectContext existingObjectWithID:objID error:&error];
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotificationName
                                                                    object:self
                                                                  userInfo:@{kAddedKey: object}];
            }
        }
    }
    
    // Event updated
    NSDictionary *updatedObjectIDs = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    if (updatedObjectIDs) {
        for (NSManagedObjectID *objID in updatedObjectIDs) {
            NSError *error = nil;
            NSManagedObject *object = [self.managedObjectContext existingObjectWithID:objID error:&error];
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kEventUpdatedNotificationName
                                                                    object:self
                                                                  userInfo:@{kUpdatedKey: object}];
            }
        }
    }
    
    // Event deleted
    NSDictionary *deletedObjectIDs = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    
    if (deletedObjectIDs) {
        for (NSManagedObjectID *objID in deletedObjectIDs) {
            NSError *error = nil;
            NSManagedObject *object = [self.managedObjectContext existingObjectWithID:objID error:&error];
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kEventDeletedNotificationName
                                                                    object:self
                                                                  userInfo:@{kDeletedKey: object}];
            }
        }
    }
}

@end
