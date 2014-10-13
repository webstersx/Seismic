//
//  SeismicAPI.h
//  Seismic
//
//  Created by Shawn Webster on 2014-10-13.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeismicAPI : NSObject

+ (instancetype) shared;

- (void) update;

@end
