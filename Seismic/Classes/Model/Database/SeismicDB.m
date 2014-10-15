//
//  SeismicDB.m
//  Seismic
//
//  Created by Shawn Webster on 2014-10-13.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

//resources: old, but still my favourite: http://www.cocoanetics.com/2012/07/multi-context-coredata/
//see section titled: "Parent/Child Contexts"

#import "SeismicDB.h"
#import <CoreData/CoreData.h>

#import "NSDictionary+SeismicData.h"

#import "Earthquake.h"

@interface SeismicDB()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void) update:(NSArray *)events inContext:(NSManagedObjectContext*)temporaryContext;
- (NSManagedObject*) entity:(NSString*)entity inContext:(NSManagedObjectContext*)context withValue:(id)value forKey:(NSString*)key;

@end

@implementation SeismicDB

+ (instancetype) shared
{
    static SeismicDB *_shared = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _shared = [[self alloc] init];
    });
    
    return _shared;
}

- (instancetype) init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}


#pragma mark - Data reading
/*! Returns all events - not sorted
 
 @see - eventsByDate
 @see - eventsByMagnitude
 @see - eventsByProximityTo:(CLLocation*)location
 */
- (NSArray*) events {
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:@"Earthquake"];
    r.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timedate" ascending:NO]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:r error:&error];
    
    return results;
}

/*! Returns all events sorted Date descending
 
 @see - events
 @see - eventsByMagnitude
 @see - eventsByProximityTo:(CLLocation*)location
 */
- (NSArray*) eventsByDate {
    return [self events];
}

/**
 Returns all events sorted Magnitude descending
 
 @see - events
 @see - eventsByDate
 @see - eventsByProximityTo:(CLLocation*)location
 */
- (NSArray*) eventsByMagnitude {
    return [[self events] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"magnitude" ascending:NO]]];
}

//TODO: implement proximity filtering
/**
 Returns all events sorted by Proximity to coordinate ascending
 
 @param the lat/lon of coordinate to compare to
 @see - events
 @see - eventsByMagnitude
 @see - eventsByDate
 */
- (NSArray*) eventsByProximityTo:(CLLocation*)location {
    return [self events];
}

#pragma mark - Data writing
/**
 Forwards the events to a temporary context to update the into the database
 */
- (void) update:(NSArray*)events {
    
    //get a temporary context to work in
    NSManagedObjectContext *context = [self temporaryContext];
    
    //don't create a retain cycles
    __unsafe_unretained SeismicDB *weakSelf = self;
    __block NSArray *blockEvents = events;
    __block NSManagedObjectContext *blockContext = context;
    
    //do updates
    [context performBlockAndWait:^{
        
        //update the objects
        [weakSelf update:blockEvents inContext:blockContext];
        //and save + propogate changes
        [weakSelf saveContext:context];
        
    }];
}

/*! 
 Performs the DB update
 @param events - the events to be added/inserted into the context
 @param temporaryContext - the temporary context in which to insert the objects
 */
- (void) update:(NSArray*)events inContext:(NSManagedObjectContext*)temporaryContext {
    //we must have a context, it must not be the main context, and it must have a parent
    NSParameterAssert(temporaryContext);
    NSParameterAssert(temporaryContext != self.managedObjectContext);
    NSParameterAssert(temporaryContext.parentContext);
    
    
    for (NSDictionary *event in events) {
        //since we know this is happening on a thread other than main, we don't care as much about performance as
        //we do about *not* crashing in case something is malformed
        @try {
            //insert or update
            
            /* //a sample, eqid is the primary key
            {
                depth = "40.90";
                eqid = c000is61;
                lat = "7.6413";
                lon = "93.6871";
                magnitude = "4.6";
                region = "Nicobar Islands, India region";
                src = us;
                timedate = "2013-07-29 22:22:48";
            }*/
            
            //sanitize the data (ie convert strings to floats where necessary)
            NSDictionary *e = [event seismicized];
            
            //check for an eqid
            NSString *eqid = e[@"eqid"];
            if (!eqid) {
                //skip this one since it's missing its unique key
                NSLog(@"Skipping: %@", e);
                continue;
            }
            
            //find the earthquake with this id
            Earthquake *earthquake = (Earthquake*)[self entity:@"Earthquake"
                                                     inContext:temporaryContext
                                                     withValue:eqid
                                                        forKey:@"eqid"];
            
            //if the object didn't exist, create it
            if (!earthquake) {
                earthquake = [NSEntityDescription insertNewObjectForEntityForName:@"Earthquake"
                                                           inManagedObjectContext:temporaryContext];
            }
            
            //iterate over the keys in the data object
            for (NSString *key in e.allKeys) {
                
                //attempt to set them, this should be okay or we should do further sanitizing
                if ([earthquake respondsToSelector:NSSelectorFromString(key)]) {
                    [earthquake setValue:e[key] forKey:key];
                }
                
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"Unable to parse object: %@", event);
            NSLog(@"%@", exception);
        }
        @finally {
            ;
        }
    }
    
}

/*! Find the first of a specific entity in the context
 @param entity - the entity name
 @param context - the context to search in
 @param value - the value to search
 @param key - the key to search on
 */
- (NSManagedObject*) entity:(NSString*)entity
                  inContext:(NSManagedObjectContext*)context
                  withValue:(id)value
                     forKey:(NSString*)key {
    NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:entity];
    r.predicate = [NSPredicate predicateWithFormat:@"%K = %@", key, value];
    r.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:r error:&error];
    
    if (error) {
        return nil;
    }
    
    if (results.count > 0) {
        return [results firstObject];
    }
    
    return nil;
    
}

#pragma mark - Database Concurrency

/*! 
 Returns a temporary context with which write operations can be performed
 */
- (NSManagedObjectContext*) temporaryContext {
    //main context must exist
    NSParameterAssert(self.managedObjectContext);
    
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [temporaryContext setParentContext:self.managedObjectContext];
    
    return temporaryContext;
}

/*! 
 Saves the temporary context and propogates the change upwards to the parent context
 @param temporaryContext - the context to be saved
 */
- (void) saveContext:(NSManagedObjectContext*)temporaryContext {
    
    //can't save the main context this way
    NSParameterAssert(temporaryContext != self.managedObjectContext);
    //context must have a parent
    NSParameterAssert(temporaryContext.parentContext);
    
    // push to parent
    NSError *error;
    if (![temporaryContext save:&error])
    {
        // handle error
        NSLog(@"Error saving temporary context: %@", error);
    }
    
    // save parent to disk asynchronously
    [temporaryContext.parentContext performBlock:^{
        NSError *error;
        if (![temporaryContext.parentContext save:&error])
        {
            NSLog(@"Error saving main context: %@", error);
        }
    }];
    
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.shawnwebster.Seismic" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Seismic" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Seismic.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
