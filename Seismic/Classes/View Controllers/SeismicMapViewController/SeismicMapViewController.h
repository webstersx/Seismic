//
//  SeismicMapViewController.h
//  Seismic
//
//  Created by Shawn Webster on 2014-10-15.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Earthquake;

@interface SeismicMapViewController : UIViewController

@property (strong, nonatomic) Earthquake *event;

@end
