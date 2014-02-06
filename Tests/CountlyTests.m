//
//  CountlyTests.m
//  CountlyTests
//
//  Created by Scott Petit on 1/13/14.
//  Copyright (c) 2014 Scott Petit. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Countly.h"
#import <OCMock/OCMock.h>
#import "CountlyTestUtility.h"

@interface CountlyTests : XCTestCase

@property (nonatomic, strong) Countly *countly;

@end

@implementation CountlyTests

- (void)setUp
{
    [super setUp];
    
    self.countly = [Countly sharedInstance];
}

- (void)tearDown
{
    self.countly = nil;
    
    [super tearDown];
}

- (void)testThatSharedInstanceIsNotNil
{
    XCTAssertNotNil([Countly sharedInstance], @"");
}

- (void)testOperatingSystemIsSetInDefaultMetrics
{
    NSDictionary *defaultMetrics = [self.countly defaultMetrics];
    
    XCTAssertNotNil(defaultMetrics[@"_os"], @"");
}

- (void)testOperatingSystemVersionIsSetInDefaultMetrics
{
    NSDictionary *defaultMetrics = [self.countly defaultMetrics];
    
    XCTAssertNotNil(defaultMetrics[@"_os_version"], @"");
}

- (void)testDeviceIsSetInDefaultMetrics
{
    NSDictionary *defaultMetrics = [self.countly defaultMetrics];
    
    XCTAssertNotNil(defaultMetrics[@"_device"], @"");
}

- (void)testResolutionIsSetInDefaultMetrics
{
    NSDictionary *defaultMetrics = [self.countly defaultMetrics];
    
    XCTAssertNotNil(defaultMetrics[@"_resolution"], @"");
}

- (void)testCarrieIsSetInDefaultMetrics
{
    id countlyMock = [OCMockObject partialMockForObject:self.countly];
    [[[countlyMock stub] andReturn:@"AT&T"] carrier];
    
    NSDictionary *defaultMetrics = [countlyMock defaultMetrics];
    
    XCTAssertNotNil(defaultMetrics[@"_carrier"], @"");
}

- (void)testLocaleIsSetInDefaultMetrics
{
    NSDictionary *defaultMetrics = [self.countly defaultMetrics];
    
    XCTAssertNotNil(defaultMetrics[@"_locale"], @"");
}

- (void)testApplicationVersionIsSetInDefaultMetrics
{
    NSDictionary *defaultMetrics = [self.countly defaultMetrics];
    
    XCTAssertNotNil(defaultMetrics[@"_app_version"], @"");
}

- (void)testBeginSessionIsFiredOnForeground
{
    [self.countly trackWithAppKey:@"key" baseURL:[NSURL URLWithString:@"http"]];
    
    id countlyMock = [OCMockObject partialMockForObject:self.countly];
    [[countlyMock expect] log:OCMOCK_ANY];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    
    [CountlyTestUtility waitForVerifiedMock:countlyMock maxDelay:1.0f];
}

- (void)testEndSessionIsFiredOnBackground
{
    [self.countly trackWithAppKey:@"key" baseURL:[NSURL URLWithString:@"http"]];
    
    id countlyMock = [OCMockObject partialMockForObject:self.countly];
    [[countlyMock expect] log:OCMOCK_ANY];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [CountlyTestUtility waitForVerifiedMock:countlyMock maxDelay:1.0f];
}

@end
