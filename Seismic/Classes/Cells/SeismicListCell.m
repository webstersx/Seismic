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

+ (NSDateFormatter*) sharedDateFormatter;

@end

@implementation SeismicListCell

- (void)awakeFromNib {
    // Initialization code
    
    self.event = self.event;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    
    NSDate *date = [self.sharedDateFormatter dateFromString:event.timedate];
    self.lblTime.text = [date timeAgo];
    
    
}

@end
