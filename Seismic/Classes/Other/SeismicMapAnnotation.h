//
//  SeismicMapAnnotation.h
//  Seismic
//
//  Created by Shawn Webster on 2014-10-15.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class Earthquake;

@interface SeismicMapAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) Earthquake *event;

@end
