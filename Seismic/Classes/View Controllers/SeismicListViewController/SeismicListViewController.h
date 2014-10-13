//
//  SeismicListViewController.h
//  Seismic
//
//  Created by Shawn Webster on 2014-10-12.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    kSeismicListDataModeDefault = 0,
    kSeismicListDataModeDate = kSeismicListDataModeDefault,
    kSeismicListDataModeMagnitude,
    kSeismicListDataModeProximity
    
} SeismicListDataMode;

@interface SeismicListViewController : UITableViewController

@property (assign, nonatomic) SeismicListDataMode dataMode;

@end
