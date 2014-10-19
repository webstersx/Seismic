//
//  SeismicListViewController.m
//  Seismic
//
//  Created by Shawn Webster on 2014-10-12.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import "SeismicListViewController.h"
#import "SeismicMapViewController.h"
#import "SeismicListCell.h"

#import "SeismicDB.h"
#import "Earthquake.h"


@interface SeismicListViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL showDistance;

@end

@implementation SeismicListViewController

//only update locations once per view load or until reset manually
static dispatch_once_t onceToken;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Seismic";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SeismicListCell" bundle:nil]
         forCellReuseIdentifier:kSeismicListCellIdentifier];
    
    //reset location updates
    onceToken = false;
    
    [self loadData];
}

- (void) loadData {
    
    SeismicDB *db = [SeismicDB shared];
    
    switch (self.dataMode) {
        case kSeismicListDataModeMagnitude: {
            self.title = @"Events by Strength";
            self.events = [db eventsByMagnitude];
            break;
        }
        case kSeismicListDataModeProximity: {
            self.title = @"Nearest to Me";
            BOOL startLocationServices = [self attemptLocationServicesPermissions];
            
            if (startLocationServices) {
                [self.locationManager startUpdatingLocation];
            } else {
                CLLocation *location = [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease];
                [self updateEventsWithLocation:location];
            }
            break;
        }
        default: {
            self.title = @"Most Recent Events";
            self.events = [db eventsByDate];
            break;
        }
    }
    
    self.showDistance = self.dataMode == kSeismicListDataModeProximity;

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MapEvent"]) {
        NSParameterAssert([sender isKindOfClass:[Earthquake class]]);
        SeismicMapViewController *mapViewController = (SeismicMapViewController*)segue.destinationViewController;
        mapViewController.event = sender;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return self.events.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    SeismicListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSeismicListCellIdentifier];

    //give the cell the event, let it handle presentation for itself
    cell.showDistance = self.showDistance;    
    cell.event = self.events[indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"MapEvent" sender:self.events[indexPath.row]];
}

- (void) dealloc {
    [_locationManager stopUpdatingLocation];
    [_locationManager setDelegate:nil];
    [_locationManager release];
    _locationManager = nil;
    
    [_events release];
    _events = nil;
    
    [super dealloc];
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SeismicListCell estimatedHeight];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SeismicListCell height];
}

#pragma mark - Location Services

- (CLLocationManager*) locationManager {
    if (!_locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (BOOL) attemptLocationServicesPermissions {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            //all is good
            return YES;
            break;
        }
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"We don't seem to have permission to use your location. Please go to the Settings app and allow Seismic under Location Services" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
            
        case kCLAuthorizationStatusNotDetermined:
        {
            
            //requires Plist key: NSLocationWhenInUseUsageDescription
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
                //special handling; don't request too much permissions or the user will probably reject
                [self.locationManager requestWhenInUseAuthorization];
            } else {
                [self.locationManager startUpdatingLocation];
                self.locationManager.delegate = self;
            }
            
            break;
        }
    }
    
    return NO;
}


- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            //reset to allow location updates once
            onceToken = false;
            
            [self.locationManager startUpdatingLocation];
            break;
        }
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusNotDetermined:
        {
            //ignore these status changes
            break;
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //get the most recent location
    CLLocation *location = [locations lastObject];
    
    //decide some arbitrary precision: 10km square
    if (location.horizontalAccuracy < 10000 &&
        location.verticalAccuracy < 10000) {
        
        
        //stop checking for location, this is good enough -- don't drain the battery and free up some resources
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
        [_locationManager release];
        _locationManager = nil;
        
        
        //so that we only ever update with a location once unless instructed to allow resetting
        dispatch_once(&onceToken, ^{
            [self updateEventsWithLocation:location];
        });
    }
    
}

- (void) updateEventsWithLocation:(CLLocation*)location {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [_events release];
    _events = nil;
    [self.tableView reloadData];
    
    __block SeismicListViewController *blockSelf = self;
    
    //push to a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //update the distances in the background and wait until done
        [[SeismicDB shared] updateDistanceFromLocation:location];
        
        //then refresh ui on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *events = [[SeismicDB shared] eventsByDistanceFrom:location];
            [blockSelf setEvents:events];
            [blockSelf.tableView reloadData];
        });
        
    });
}


@end
