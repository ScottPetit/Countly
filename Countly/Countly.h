//
//  Countly.h
//  Countly
//
//  Created by Scott Petit on 1/13/14.
//  Copyright (c) 2014 Scott Petit. All rights reserved.
//

extern NSString * const kCountlyCountUserInfoKey;
extern NSString * const kCountlySumUserInfoKey;
extern NSString * const kCountlySegmentationUserInfoKey;

@interface Countly : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSDictionary *defaultPayload;

- (void)trackWithAppKey:(NSString *)appKey baseURL:(NSURL *)baseURL;

//Event Tracking
- (void)trackEvent:(NSString *)event;
- (void)trackEvent:(NSString *)event withCount:(NSInteger)count;
- (void)trackEvent:(NSString *)event withCount:(NSInteger)count sum:(CGFloat)sum;
- (void)trackEvent:(NSString *)event withCount:(NSInteger)count segmentation:(NSDictionary *)segmentation;
- (void)trackEvent:(NSString *)event withCount:(NSInteger)count segmentation:(NSDictionary *)segmentation sum:(CGFloat)sum;

- (void)trackEventWithNotificationName:(NSString *)notificationName;

@end

@interface Countly (Metrics)

- (NSString *)operatingSystem;
- (NSString *)operatingSystemVersion;
- (NSString *)device;
- (NSNumber *)resolution;
- (NSString *)carrier;
- (NSString *)locale;
- (NSString *)applicationVersion;

- (NSDictionary *)defaultMetrics;

@end
