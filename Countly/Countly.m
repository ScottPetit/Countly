//
//  Countly.m
//  Countly
//
//  Created by Scott Petit on 1/13/14.
//  Copyright (c) 2014 Scott Petit. All rights reserved.
//

#import "Countly.h"
@import CoreTelephony;

@interface Countly ()

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLSession *URLSession;
@property (nonatomic, strong) NSMutableURLRequest *URLRequest;

@property (nonatomic, strong) NSDate *startDate;

- (void)beginSession;
- (void)endSession;

- (NSString *)JSONStringFromDictionary:(NSDictionary *)dictionary;
- (NSString *)stringByURLEscapingString:(NSString *)string;

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification;
- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification;

@end

@implementation Countly

#pragma mark - Init

+ (instancetype)sharedInstance
{
    static Countly *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties

- (NSDictionary *)defaultPayload
{
    if (!_defaultPayload)
    {
        UIDevice *currentDevice = [UIDevice currentDevice];
        NSString *deviceID = [[currentDevice identifierForVendor] UUIDString];
        
        _defaultPayload = @{@"app_key": self.appKey, @"device_id": deviceID};
    }
    return _defaultPayload;
}

- (NSURLSession *)URLSession
{
    if (!_URLSession)
    {
        _URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _URLSession;
}

- (NSMutableURLRequest *)URLRequest
{
    if (!_URLRequest)
    {
        _URLRequest = [NSMutableURLRequest requestWithURL:self.baseURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [_URLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_URLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_URLRequest setHTTPMethod:@"Post"];
    }
    return _URLRequest;
}

#pragma mark - Public

- (void)startWithAppKey:(NSString *)appKey baseURL:(NSURL *)baseURL
{
    NSParameterAssert(appKey.length);
    NSParameterAssert(baseURL);
    
    if (!appKey.length && !baseURL)
    {
        return;
    }
    
    self.appKey = appKey;
    self.baseURL = baseURL;
}

- (void)log:(id)payload
{
    NSString *message = nil;
    
    if ([payload isKindOfClass:[NSDictionary class]])
    {
        message = [self JSONStringFromDictionary:payload];
        message = [self stringByURLEscapingString:message];
    }
    else if ([payload isKindOfClass:[NSString class]])
    {
        message = payload;
    }
    else
    {
        NSLog(@"Attempting to log unsupported payload, this could throw an exception but currently just returns");
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"1/?%@", message] relativeToURL:self.baseURL];
    [self.URLRequest setURL:URL];
    
    NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:self.URLRequest completionHandler:nil];

    [dataTask resume];
}

- (NSString *)JSONStringFromDictionary:(NSDictionary *)dictionary
{
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    for (id key in [dictionary allKeys])
    {
        NSString *keyValue = [key stringByAppendingFormat:@"=%@", dictionary[key]];
        
        if (!mutableString.length)
        {
            [mutableString appendString:keyValue];
        }
        else
        {
            [mutableString appendFormat:@"&%@", keyValue];
        }
    }
    
    return [mutableString copy];
}

- (NSString *)stringByURLEscapingString:(NSString *)string
{
    CFStringRef escapedString =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)string,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
	return (__bridge NSString*)escapedString;
}

#pragma mark - Private

- (void)beginSession
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:self.defaultPayload];
    
    [payload setObject:@"1.0" forKey:@"sdk_version"];
    [payload setObject:@"1" forKey:@"begin_session"];
    [payload setObject:[self defaultMetrics] forKey:@"metrics"];
    
    self.startDate = [NSDate date];
    
    [self log:payload];
}

- (void)endSession
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:self.defaultPayload];
    
    [payload setObject:@"1" forKey:@"end_session"];
    
    if (self.startDate)
    {
        NSTimeInterval sessionDuration = [[NSDate date] timeIntervalSinceDate:self.startDate];
        [payload setObject:[@(sessionDuration) stringValue] forKey:@"session_duration"];
    }
    
    [self log:payload];
}

#pragma mark - NSNotificationCenter

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
    [self beginSession];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self endSession];
}

#pragma mark - Metrics

- (NSString *)operatingSystem
{
    return @"iOS";
}

- (NSString *)operatingSystemVersion
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    return [currentDevice systemVersion];
}

- (NSString *)device
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    return [currentDevice model];
}

- (NSString *)resolution
{
    CGFloat resolution = [[UIScreen mainScreen] scale];
    
    return [@(resolution) stringValue];
}

- (NSString *)carrier
{
    NSString *carrierName = nil;
    
    if (NSClassFromString(@"CTTelephonyNetworkInfo"))
	{
		CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
		CTCarrier *carrier = [netinfo subscriberCellularProvider];
        carrierName = [carrier carrierName];
	}
    
    return carrierName;
}

- (NSString *)locale
{
    return [[NSLocale currentLocale] localeIdentifier];
}

- (NSString *)applicationVersion
{
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (versionString.length == 0)
    {
        versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    }
    
    return versionString;
}

- (NSDictionary *)defaultMetrics
{
    NSMutableDictionary *metrics = [NSMutableDictionary dictionary];
    
    [metrics setObject:[self operatingSystem] forKey:@"_os"];
    [metrics setObject:[self operatingSystemVersion] forKey:@"_os_version"];
    [metrics setObject:[self device] forKey:@"_device"];
    [metrics setObject:[self resolution] forKey:@"_resolution"];
    [metrics setObject:[self locale] forKey:@"_locale"];
    [metrics setObject:[self applicationVersion] forKey:@"_app_version"];
    
    return [metrics copy];
}

@end
