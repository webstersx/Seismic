//
//  Earthquake.h
//  
//
//  Created by Shawn Webster on 2014-10-15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Earthquake : NSManagedObject

@property (nonatomic, retain) NSNumber * depth;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * eqid;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSNumber * magnitude;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * src;
@property (nonatomic, retain) NSString * timedate;

@end
