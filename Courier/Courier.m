//
//  Courier.m
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
//

#import "Courier.h"
#import "Courier+Get.h"
#import "Courier+Post.h"

#import <UIKit/UIDevice.h>
#import <UIKit/UIApplication.h>

#import "NSData+Courier.h"

#import "Reachability.h"

@implementation Courier

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    dispatch_once(&pred, ^{
        _sharedInstance = [Courier new];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableDictionary *defaultHeader = [[NSMutableDictionary alloc] init];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [defaultHeader setValue:@"application/json" forKey:@"Accept"];
        
        // Accept-Encoding HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.3
        [defaultHeader setValue:@"gzip" forKey:@"Accept-Encoding"];
        
        // Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
        NSString *preferredLanguageCodes = [[NSLocale preferredLanguages] componentsJoinedByString:@", "];
        [defaultHeader setValue:[NSString stringWithFormat:@"%@, en-us;q=0.8", preferredLanguageCodes] forKey:@"Accept-Language"];
        
        // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
        
        NSString *bundleIdentifierString = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
        NSString *bundleVersionKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        NSString *systemName = [[UIDevice currentDevice] systemName];
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        NSString *model = [[UIDevice currentDevice] model];
        [defaultHeader setValue:[NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@", bundleIdentifierString, bundleVersionKey, @"unknown", systemName, systemVersion, model] forKey:@"User-Agent"];
        
        _defaultHeader = defaultHeader;
    }
    return self;
}

+ (Courier *)courier
{
    Courier *courier = [Courier new];
    courier.shouldHandleCookies = NO;
    return courier;
}

+ (Courier *)newCourierWithBaseAPIPath:(NSString *)baseAPIPath
                      andMainQueueName:(NSString *)queueName
{
    Courier *courier = [Courier new];
    courier.baseAPIPath = baseAPIPath;
    courier.mainQueueName = queueName;
    return courier;
}

#pragma mark - API

- (CDOperation *)addOperationForPath:(NSString *)path 
                          withMethod:(CRRequestMethod)method
                              header:(NSDictionary *)header
                    andURLParameters:(NSDictionary *)parameters
               andHTTPBodyParameters:(NSDictionary *)httpBodyParameters
                        toQueueNamed:(NSString *)queueName
                             success:(CRRequestOperationSuccessBlock)success 
                             failure:(CRRequestOperationFailureBlock)failure
{        
    if (self.baseAPIPath && [path rangeOfString:@"http"].location == NSNotFound) {
        NSMutableString *newPath = [self.baseAPIPath mutableCopy];
        
        if ([path hasPrefix:@"/"]) {
            [newPath appendFormat:@"%@", path];
        } else {
            [newPath appendFormat:@"/%@", path];            
        }
        
        path = newPath;
    }
    
    DLog(@"Path: %@", path);
    
    // Test reachability
    if (![self isPathReachable:path unreachableBlock:failure]) {
        WLog(@"Not reachable: %@", path);
        return nil;
    }
    
    CRRequest *request = [CRRequest requestWithMethod:method 
                                              forPath:path 
                                    withURLParameters:parameters
                                andHTTPBodyParameters:httpBodyParameters
                                            andHeader:header
                                  shouldHandleCookies:self.shouldHandleCookies];
    
    CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request
                                                                     success:success
                                                                     failure:failure];
        
    if (!queueName) queueName = [self queueNameForOperation:operation];
    
    [self addOperation:operation toQueueNamed:queueName];
    
    // Network activity
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    CDOperationQueueProgressObserverCompletionBlock completionBlock = ^(void) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    };
    
    [self addProgressObserverToQueueNamed:queueName
                        withProgressBlock:nil
                       andCompletionBlock:completionBlock];
    
    return operation;
}

- (CDOperation *)putPath:(NSString *)path 
           URLParameters:(NSDictionary *)urlParameters
                 success:(CRRequestOperationSuccessBlock)success
                 failure:(CRRequestOperationFailureBlock)failure
{    
    return [self addOperationForPath:path 
                          withMethod:CRRequestMethodPUT
                              header:[self defaultHeader]
                    andURLParameters:urlParameters
               andHTTPBodyParameters:nil
                        toQueueNamed:nil
                             success:success 
                             failure:failure];
}

- (CDOperation *)deletePath:(NSString *)path 
              URLParameters:(NSDictionary *)urlParameters
                    success:(CRRequestOperationSuccessBlock)success
                    failure:(CRRequestOperationFailureBlock)failure
{    
    return [self addOperationForPath:path 
                          withMethod:CRRequestMethodDELETE
                              header:[self defaultHeader]
                    andURLParameters:urlParameters
               andHTTPBodyParameters:nil
                        toQueueNamed:nil
                             success:success 
                             failure:failure];
}

#pragma mark - Header

- (void)setBasicAuthUsername:(NSString *)username 
                 andPassword:(NSString *)password 
{
    NSString *authHeader = [NSString stringWithFormat:@"%@:%@", username, password];
    NSString *encodedAuthHeader = [[NSData dataWithBytes:[authHeader UTF8String] 
                                                  length:[authHeader length]] base64EncodedString];
    
    [self.defaultHeader setValue:[NSString stringWithFormat:@"Basic %@", encodedAuthHeader] 
                          forKey:@"Authorization"];
}

#pragma mark - Conductor

- (NSString *)queueNameForOperation:(NSOperation *)operation
{
    if (_mainQueueName) return self.mainQueueName;
    return [super queueNameForOperation:operation];
}

#pragma mark - Cookies

- (void)deleteCookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:cookie];
    }
}

#pragma mark - Reachability

- (BOOL)isBaseAPIPathReachable
{
    return [self isPathReachable:[self baseAPIPath]
                unreachableBlock:nil];
}

- (BOOL)isPathReachable:(NSString *)path 
       unreachableBlock:(CRRequestOperationFailureBlock)unreachableBlock
{    
    if (!path) return NO;
    
    // Build reachability with address
    struct sockaddr_in address;
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons(9000);
    address.sin_addr.s_addr = inet_addr((const char*)[path UTF8String]);
    Reachability *reach = [Reachability reachabilityWithAddress:&address];
    
    if ([reach currentReachabilityStatus] == NotReachable) {
        WLog(@"\nReachability failed! \n%@ is not reachable", path);
        
        if (unreachableBlock) {
            // Fail with unreachable flag set to yes
            unreachableBlock(nil, nil, nil, YES);
        }
        
        return NO;
    } else {
        return YES;
    }
}

@end
