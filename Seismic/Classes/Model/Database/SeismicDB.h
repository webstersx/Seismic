//
//  SeismicDB.h
//  Seismic
//
//  Created by Shawn Webster on 2014-10-13.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Earthquake;

@interface SeismicDB : NSObject

+ (instancetype) shared;

- (void) update:(NSArray*)events;
- (void) updateDistanceFromLocation:(CLLocation*)location;

- (Earthquake*) earthquakeWithEqid:(NSString*)eqid;
- (NSArray*) events;
- (NSArray*) eventsByDate;
- (NSArray*) eventsByMagnitude;
- (NSArray*) eventsByDistanceFrom:(CLLocation*)location;

- (void) removeAllObjects;

@end
