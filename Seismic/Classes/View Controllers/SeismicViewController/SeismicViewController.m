//
//  SeismicViewController.m
//  Seismic
//
//  Created by Shawn Webster on 2014-10-13.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import "SeismicViewController.h"
#import "SeismicListViewController.h"

#define kSeismicDataModeTitleKey @"kSeismicDataModeTitleKey"
#define kSeismicDataModeSegueKey @"kSeismicDataModeSegueKey"
#define kSeismicDataModeModeKey @"kSeismicDataModeControllerKey"

#define kSeismicListSegue @"kSeismicListSegue"
#define kSeismicGridSegue @"kSeismicGridSegue"
#define kSeismicMapSegue @"kSeismicMapSegue"

@interface SeismicViewController ()

@property (strong, nonatomic) NSArray *modes;

@end

@implementation SeismicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Seismic";
    
    self.modes = [NSArray arrayWithObjects:
                  @{kSeismicDataModeTitleKey:@"List - Most recent first",
                    kSeismicDataModeSegueKey:kSeismicListSegue,
                    kSeismicDataModeModeKey:@(kSeismicListDataModeDate)},
                  
                  @{kSeismicDataModeTitleKey:@"List - Strongest first",
                    kSeismicDataModeSegueKey:kSeismicListSegue,
                    kSeismicDataModeModeKey:@(kSeismicListDataModeMagnitude)},
                  
                  @{kSeismicDataModeTitleKey:@"List - Nearest to me first",
                    kSeismicDataModeSegueKey:kSeismicListSegue,
                    kSeismicDataModeModeKey:@(kSeismicListDataModeProximity)},
                  @{kSeismicDataModeTitleKey:@"Map",
                    kSeismicDataModeSegueKey:kSeismicMapSegue,
                    kSeismicDataModeModeKey:@(0)},
                  nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.modes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellReuseIdentifier = @"SeismicDataModeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    //additional cell setup
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *mode = self.modes[indexPath.row];
    
    cell.textLabel.text = mode[kSeismicDataModeTitleKey];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *mode = self.modes[indexPath.row];
    
    NSString *segueIdentifier = mode[kSeismicDataModeSegueKey];

    if ([segueIdentifier isEqualToString:kSeismicListSegue]) {
        [self performSegueWithIdentifier:segueIdentifier sender:mode];
    } else if ([segueIdentifier isEqualToString:kSeismicGridSegue]) {
        
    } else if ([segueIdentifier isEqualToString:kSeismicMapSegue]) {
        [self performSegueWithIdentifier:segueIdentifier sender:nil];
    } else {
        //I don't know how to perform this segue
    }
    
}

- (void) dealloc {
    [_modes release];
    _modes = nil;
    
    [super dealloc];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:kSeismicListSegue]) {
        SeismicListViewController *listViewController = (SeismicListViewController*)segue.destinationViewController;
        
        NSDictionary *dataMode = (NSDictionary*)sender;
        SeismicListDataMode mode = (SeismicListDataMode)[dataMode[kSeismicDataModeModeKey] integerValue];
        [listViewController setDataMode:mode];
    } 
    
}

@end
