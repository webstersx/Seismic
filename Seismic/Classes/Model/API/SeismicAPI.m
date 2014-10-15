//
//  SeismicAPI.m
//  Seismic
//
//  Created by Shawn Webster on 2014-10-13.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import "SeismicAPI.h"
#import <AFNetworking/AFNetworking.h>
#import "SeismicDB.h"

#define kSeismicAPIBaseURLString @"http://www.seismi.org"
//http://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php -> better data source

@interface SeismicAPI()

@property (strong, nonatomic) AFHTTPRequestOperationManager *api;

@end

@implementation SeismicAPI

+ (instancetype) shared
{
    static SeismicAPI *_shared = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _shared = [[self alloc] init];
    });
    
    return _shared;
}

- (instancetype) init
{
    if (self = [super init])
    {
        //additional setup if required
    }
    
    return self;
}

/**
 Returns the API operation manager if it already exists or creates it first and does initial setup if necessary
 */
- (AFHTTPRequestOperationManager*) api {
    
    if (!_api) {
        NSURL *url = [NSURL URLWithString:kSeismicAPIBaseURLString];
        self.api = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        
        //add acceptable content types since they don't specify proper headers
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        [responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:
                                                       @"application/json",
                                                       @"text/html",
                                                       @"text/plain", nil]];
        self.api.responseSerializer = responseSerializer;
    }
    
    return _api;
}

/**
 Executes an update API operation and forwards the earthquake objects from the response forward to the Database
 */
- (void) update {
    [self.api GET:@"/api/eqs/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //put objects into database
        //format: { "count":0, "earthquakes":[]}
        NSArray *events = responseObject[@"earthquakes"];
        
        [[SeismicDB shared] update:events];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) dealloc {
    //free up the api
    [_api.operationQueue cancelAllOperations];
    [_api release];
    _api = nil;
    
    [super dealloc];
}

@end
