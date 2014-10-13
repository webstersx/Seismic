//
//  SeismicListCell.m
//  Seismic
//
//  Created by Shawn Webster on 2014-10-12.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import "SeismicListCell.h"
#import "Earthquake.h"

@implementation SeismicListCell

- (void)awakeFromNib {
    // Initialization code
    
    self.event = self.event;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setEvent:(Earthquake *)event {
    _event = event;
    
    self.textLabel.text = [NSString stringWithFormat:@"%@ - %@", event.magnitude, event.region];
    
}

@end
