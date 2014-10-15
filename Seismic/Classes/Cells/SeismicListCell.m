//
//  SeismicListCell.m
//  Seismic
//
//  Created by Shawn Webster on 2014-10-12.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import "SeismicListCell.h"
#import "Earthquake.h"
#import "NSDate+TimeAgo.h"

@interface SeismicListCell()

@property (strong, nonatomic) IBOutlet UILabel *lblMagnitude;
@property (strong, nonatomic) IBOutlet UILabel *lblRegion;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;

- (NSDateFormatter*) sharedDateFormatter;
- (NSNumberFormatter*) sharedNumberFormatter;

@end

@implementation SeismicListCell

- (void) dealloc {
    _event = nil;
    [_lblMagnitude release];
    [_lblRegion release];
    [_lblTime release];
    
    [super dealloc];
}

- (NSDateFormatter*) sharedDateFormatter
{
    
    static NSDateFormatter *_sharedFormatter = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedFormatter = [[NSDateFormatter alloc] init];
        _sharedFormatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
    });
    
    return _sharedFormatter;
}

- (NSNumberFormatter*) sharedNumberFormatter
{
    static NSNumberFormatter *_sharedFormatter = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedFormatter = [[NSNumberFormatter alloc] init];
        [_sharedFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_sharedFormatter setGroupingSeparator:@","];
        //note: doesn't handle negatives -- NSValueTransformer feels like the better option
        [_sharedFormatter setPositiveSuffix:@"km away"];
    });
    
    return _sharedFormatter;
}


- (void) setEvent:(Earthquake *)event {
    _event = event;
    
    //enforce .0 to display
    self.lblMagnitude.text = [NSString stringWithFormat:@"%.1f", event.magnitude.floatValue];
    //do something fun so the ones with higher magnitude appear more important
    self.lblMagnitude.font = [UIFont boldSystemFontOfSize:(4.5 * event.magnitude.floatValue)];
    
    //an arbitrary calculation to make the magnitude text more red as the number gets larger,
    //4 = 0.267
    //8.4+ = 1.0
    self.lblMagnitude.textColor = [UIColor colorWithRed:(event.magnitude.floatValue / 6.0f) - 0.4
                                                  green:0.1f
                                                   blue:0.1f
                                                  alpha:1];
    
    self.lblRegion.text = event.region;
    
    //show either distance or time
    //NOTE: it might be a better choice to use an NSValueTransformer for these to give
    //more flexibility of how it's displayed with less logic in the cell / categories
    if (!self.showDistance) {
        NSDate *date = [self.sharedDateFormatter dateFromString:event.timedate];
        self.lblTime.text = [date timeAgo];
    } else {
        NSNumber *km = @(event.distance.integerValue / 1000);
        self.lblTime.text = [[self sharedNumberFormatter] stringFromNumber:km];
    }
    
    
}

@end
