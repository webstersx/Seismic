//
//  Earthquake.h
//  Seismic
//
//  Created by Shawn Webster on 2014-10-13.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Earthquake : NSManagedObject

@property (nonatomic, retain) NSNumber * depth;
@property (nonatomic, retain) NSString * eqid;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSNumber * magnitude;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * src;
@property (nonatomic, retain) NSString * timedate;

@end
