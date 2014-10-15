//
//  NSDate+TimeAgo.m
//  Seismic
//
//  Created by Shawn Webster on 2014-10-15.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import "NSDate+TimeAgo.h"

@implementation NSDate (TimeAgo)

- (NSString*) timeAgo {
    
    //get time interval since date
    NSDate *now = [NSDate date];
    //must calculate against now so the number is positive
    if ([now timeIntervalSinceDate:self] < 60) {
        return @"now";
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSCalendarUnitMinute|
                                               NSCalendarUnitHour|
                                               NSCalendarUnitDay|
                                               NSCalendarUnitMonth|
                                               NSCalendarUnitYear)
                                     fromDate:self
                                       toDate:[NSDate date]
                                      options:0];
    NSInteger amount = 0;
    NSString *unit = @"";
    
    if (comps.year) {
        unit = @"year";
        amount = comps.year;
    } else if (comps.month) {
        unit = @"month";
        amount = comps.month;
    } else if (comps.day) {
        unit = @"day";
        amount = comps.day;
    } else if (comps.hour) {
        unit = @"hour";
        amount = comps.hour;
    } else if (comps.minute) {
        unit = @"minute";
        amount = comps.minute;
    } else {
        return @"a really long time ago";
    }
    
    return [NSString stringWithFormat:@"%ld %@%@ ago", (long)amount, unit, amount == 1 ? @"": @"s"];
    
}

@end
