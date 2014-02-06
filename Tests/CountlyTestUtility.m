//
//  CountlyTestUtility.m
//  Countly
//
//  Created by Scott Petit on 2/6/14.
//  Copyright (c) 2014 Scott Petit. All rights reserved.
//

#import "CountlyTestUtility.h"
#import <OCMock/OCMock.h>

@implementation CountlyTestUtility

+ (void)waitForVerifiedMock:(OCMockObject *)mockObject maxDelay:(NSTimeInterval)delay
{
    NSTimeInterval interval = 0;
    while (interval < delay)
    {
        @try
        {
            [mockObject verify];
            return;
        }
        @catch (NSException *e) {}
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        interval += 0.5;
    }
    [mockObject verify];
}

@end
