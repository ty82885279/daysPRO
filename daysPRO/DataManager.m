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


+ (DataManager*)sharedManager {
	static dispatch_once_t once;
	static DataManager *sharedManager;
    
    dispatch_once(&once, ^{
        sharedManager = [[DataManager alloc] init];
    });
    
    return sharedManager;
}


#pragma mark -
#pragma mark Core Data stack

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

#pragma mark -
#pragma mark Adding persistent stores

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
    
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:storeURL
                                                    options:options
                                                      error:&error];
    if (error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}


#pragma mark -
#pragma mark Save Context

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

#pragma mark -
#pragma mark Events

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
    
    // Sort events in descending order
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
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}
- (Event *)updateEvent:(Event *)event withName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate details:(NSString *)details {
    event.name = name;
    event.startDate = startDate;
    event.endDate = endDate;
    event.details = details;
    return event;
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
    NSURL *url = [NSURL URLWithString:@"https://eaststudios.fi/api/days/defaultEvents.json"];
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
                
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[startDateString intValue]];
                NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[endDateString intValue]];
                
                NSDate *localStartDate = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:startDate];
                NSDate *localEndDate = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:endDate];
                
                if (![[NSUserDefaults standardUserDefaults] valueForKey:uniqueServerEventID]) {
                [self createEventWithName:name
                                startDate:localStartDate
                                  endDate:localEndDate
                                  details:details
                                    image:nil];
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

- (void)addChristmasEvents {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    //CHRISTMAS DAY
    NSDateComponents *thisYearDayComponents = [[NSDateComponents alloc] init];
    NSDateComponents *lastYearDayComponents = [[NSDateComponents alloc] init];
    
    [thisYearDayComponents setYear:[[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year]];
    [thisYearDayComponents setMonth:12];
    [thisYearDayComponents setDay:25];
    [thisYearDayComponents setHour:9];
    [thisYearDayComponents setMinute:0];
    [thisYearDayComponents setSecond:0];
    NSDate *thisYearsDay = [gregorianCalendar dateFromComponents:thisYearDayComponents];
    
    [lastYearDayComponents setYear:[[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year] - 1 ];
    [lastYearDayComponents setMonth:12];
    [lastYearDayComponents setDay:25];
    [lastYearDayComponents setHour:9];
    [lastYearDayComponents setMinute:0];
    [lastYearDayComponents setSecond:0];
    NSDate *lastYearsDay = [gregorianCalendar dateFromComponents:lastYearDayComponents];
    
    [self createEventWithName:NSLocalizedString(@"Christmas Day", nil)
                    startDate:lastYearsDay
                      endDate:thisYearsDay
                      details:nil
                        image:[UIImage imageNamed:@"christmas.jpg"]];
    
    //CHRISTMAS EVE
    NSDateComponents *thisYearEveComponents = [[NSDateComponents alloc] init];
    NSDateComponents *lastYearEveComponents = [[NSDateComponents alloc] init];
    
    [thisYearEveComponents setYear:[[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year]];
    [thisYearEveComponents setMonth:12];
    [thisYearEveComponents setDay:24];
    [thisYearEveComponents setHour:9];
    [thisYearEveComponents setMinute:0];
    [thisYearEveComponents setSecond:0];
    NSDate *thisYearsEve = [gregorianCalendar dateFromComponents:thisYearEveComponents];
    
    [lastYearEveComponents setYear:[[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year] - 1 ];
    [lastYearEveComponents setMonth:12];
    [lastYearEveComponents setDay:24];
    [lastYearEveComponents setHour:9];
    [lastYearEveComponents setMinute:0];
    [lastYearEveComponents setSecond:0];
    NSDate *lastYearsEve = [gregorianCalendar dateFromComponents:lastYearEveComponents];
    
    [self createEventWithName:NSLocalizedString(@"Christmas Eve", nil)
                    startDate:lastYearsEve
                      endDate:thisYearsEve
                      details:nil
                        image:[UIImage imageNamed:@"christmas.jpg"]];
    [self saveContext];
    
}

- (void)createDefaultEvents {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    //
    // New Year
    [comps setYear:[[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year] + 1]; // current year + 1 = next year
    [comps setMonth:1];
    [comps setDay:1];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *nextYear = [gregorianCalendar dateFromComponents:comps];
    // Current year
    [comps setYear:[[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year]]; // current year
    [comps setMonth:1];
    [comps setDay:1];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *firstDayOfTheYear = [gregorianCalendar dateFromComponents:comps];

    firstDayOfTheYear = [NSDate dateWithTimeInterval:[[NSTimeZone localTimeZone] secondsFromGMT] sinceDate:firstDayOfTheYear]; // time zone offset
    
    [self createEventWithName:NSLocalizedString(@"New Year", nil)
                    startDate:firstDayOfTheYear
                      endDate:nextYear
                      details:nil
                        image:nil];
    [self saveContext];
    
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

#pragma mark -
#pragma mark iCloud notifications

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


#pragma mark -
#pragma mark Model notifications

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
