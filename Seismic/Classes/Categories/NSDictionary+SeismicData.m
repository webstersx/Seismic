//
//  NSDictionary+SeismicData.m
//  Seismic
//
//  Created by Shawn Webster on 2014-10-13.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import "NSDictionary+SeismicData.h"

@implementation NSDictionary (SeismicData)

- (NSDictionary*) seismicized {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self];
    
    //assumed keys
    NSArray *floatKeys = @[@"depth", @"lat", @"lon", @"magnitude"];
    
    //converts values to floats instead of strings for ones we may want to compute on
    for (NSString *key in floatKeys) {
        id value = self[key];
        
        if (value) {
            //expect api to provide strings
            if ([value isKindOfClass:[NSString class]]) {
                NSString *stringValue = (NSString*)value;
                dict[key] = @(stringValue.floatValue);
            } else if ([value isKindOfClass:[NSNumber class]]) {
                //weird, they fixed it to provide floats
                dict[key] = value;
            }
        }
    }
    
    return dict;
    
}

@end
