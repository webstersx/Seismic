//
//  SeismicMapAnnotation.m
//  Seismic
//
//  Created by Shawn Webster on 2014-10-15.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import "SeismicMapAnnotation.h"
#import "Earthquake.h"

@implementation SeismicMapAnnotation

- (CLLocationCoordinate2D) coordinate {
    return CLLocationCoordinate2DMake(self.event.lat.doubleValue,
                                      self.event.lon.doubleValue);
}

- (NSString*) title {
    return self.event.region;
}

- (NSString*) subtitle {
    return self.event.timedate;
}

- (void) dealloc {
    [_event release];
    _event = nil;
    
    [super dealloc];
}

@end
