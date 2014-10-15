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


@interface SeismicListViewController ()

@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation SeismicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Seismic";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SeismicListCell" bundle:nil]
         forCellReuseIdentifier:kSeismicListCellIdentifier];
    
    [self loadData];
}

- (void) loadData {
    
    SeismicDB *db = [SeismicDB shared];
    
    switch (self.dataMode) {
        case kSeismicListDataModeMagnitude: {
            self.events = [db eventsByMagnitude];
            break;
        }
        case kSeismicListDataModeProximity: {
            CLLocation *location = [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease];
            self.events = [db eventsByProximityTo:location];
            break;
        }
        default: {
            
            self.events = [db eventsByDate];
            break;
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.event = self.events[indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"MapEvent" sender:self.events[indexPath.row]];
}

- (void) dealloc {
    
    [_events release];
    _events = nil;
    
    [super dealloc];
}

@end
