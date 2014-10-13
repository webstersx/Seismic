//
//  SeismicDB.h
//  Seismic
//
//  Created by Shawn Webster on 2014-10-13.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SeismicDB : NSObject

+ (instancetype) shared;

- (void) update:(NSArray*)events;

- (NSArray*) events;
- (NSArray*) eventsByDate;
- (NSArray*) eventsByMagnitude;
- (NSArray*) eventsByProximityTo:(CLLocation*)location;

@end
