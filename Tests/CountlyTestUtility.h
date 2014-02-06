//
//  CountlyTestUtility.h
//  Countly
//
//  Created by Scott Petit on 2/6/14.
//  Copyright (c) 2014 Scott Petit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountlyTestUtility : NSObject

+ (void)waitForVerifiedMock:(id)mockObject maxDelay:(NSTimeInterval)timeInterval;

@end
