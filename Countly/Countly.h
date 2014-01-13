//
//  Countly.h
//  Countly
//
//  Created by Scott Petit on 1/13/14.
//  Copyright (c) 2014 Scott Petit. All rights reserved.
//

@interface Countly : NSObject

+ (instancetype)sharedInstance;

- (void)startWithAppKey:(NSString *)appKey baseURL:(NSURL *)baseURL;

- (void)log:(id)payload;

@end

@interface Countly (Metrics)

- (NSString *)operatingSystem;
- (NSString *)operatingSystemVersion;
- (NSString *)device;
- (NSString *)resolution;
- (NSString *)carrier;
- (NSString *)locale;
- (NSString *)applicationVersion;

- (NSDictionary *)defaultMetrics;

@end
