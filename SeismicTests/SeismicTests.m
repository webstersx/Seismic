//
//  SeismicTests.m
//  SeismicTests
//
//  Created by Shawn Webster on 2014-10-12.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "SeismicDB.h"
#import "SeismicAPI.h"
#import "Earthquake.h"

@interface SeismicTests : XCTestCase

@end

@implementation SeismicTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [[SeismicDB shared] removeAllObjects];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[SeismicDB shared] removeAllObjects];
    
    [super tearDown];
}

- (void) testEarthquakeCanBeInserted {
    

    Earthquake *earthquake = nil;
    
    NSDictionary *testEvent = @{
        @"depth":@"40.90",
        @"eqid":@"c000is61",
        @"lat":@"7.6413",
        @"lon":@"93.6871",
        @"magnitude":@"4.6",
        @"region":@"Nicobar Islands, India region",
        @"src":@"us",
        @"timedate":@"2013-07-29 22:22:48"
        };
    
    earthquake = [[SeismicDB shared] earthquakeWithEqid:testEvent[@"eqid"]];
    XCTAssertEqualObjects(earthquake, nil, @"Earthquake doesn't exist before insert");
    
    [[SeismicDB shared] update:@[testEvent]];
    
    earthquake = [[SeismicDB shared] earthquakeWithEqid:testEvent[@"eqid"]];
    XCTAssert(earthquake, @"Earthquake exists after insert");
    
}

@end
