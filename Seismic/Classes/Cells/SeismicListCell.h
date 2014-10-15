//
//  SeismicListCell.h
//  Seismic
//
//  Created by Shawn Webster on 2014-10-12.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Earthquake;

#define kSeismicListCellIdentifier @"SeismicListCell"


@interface SeismicListCell : UITableViewCell

@property (unsafe_unretained, nonatomic) Earthquake *event;

@property (assign, nonatomic) BOOL showDistance;

@end
