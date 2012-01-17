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
#import "NSData+Courier.h"


@implementation Courier

@synthesize baseAPIPath, shouldHandleCookies;

+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    dispatch_once(&pred, ^{
        _sharedInstance = [self courier];
    });
    return _sharedInstance;
}

+ (Courier *)courier {
    Courier *courier = [[self alloc] init];
    courier.shouldHandleCookies = NO;
    return courier;
}

#pragma mark - API

- (void)addOperationForPath:(NSString *)path 
                 withMethod:(CRRequestMethod)method
                     header:(NSDictionary *)header
           andURLParameters:(NSDictionary *)parameters
      andHTTPBodyParameters:(NSDictionary *)httpBodyParameters
                    success:(CRRequestOperationSuccessBlock)success 
                    failure:(CRRequestOperationFailureBlock)failure {
    
    
    if (self.baseAPIPath && [path rangeOfString:@"http"].location == NSNotFound) {
        NSMutableString *newPath = [self.baseAPIPath mutableCopy];
        [newPath appendFormat:@"/%@", path];
        path = newPath;
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
    
    [self addOperation:operation];
}

- (void)getPath:(NSString *)path 
  URLParameters:(NSDictionary *)urlParameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path 
                   withMethod:CRRequestMethodGET
                       header:[self defaultHeader]
             andURLParameters:urlParameters
        andHTTPBodyParameters:nil
                      success:success 
                      failure:failure];
}

- (void)getPath:(NSString *)path
     withHeader:(NSDictionary *)header
  URLParameters:(NSDictionary *)urlParameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path 
                   withMethod:CRRequestMethodGET
                       header:header
             andURLParameters:urlParameters
        andHTTPBodyParameters:nil
                      success:success 
                      failure:failure];
}

- (void)putPath:(NSString *)path 
  URLParameters:(NSDictionary *)urlParameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path 
                   withMethod:CRRequestMethodPUT
                       header:[self defaultHeader]
             andURLParameters:urlParameters
        andHTTPBodyParameters:nil
                      success:success 
                      failure:failure];
}

- (void)postPath:(NSString *)path 
   URLParameters:(NSDictionary *)urlParameters
         success:(CRRequestOperationSuccessBlock)success
         failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path
                   withMethod:CRRequestMethodPOST
                       header:[self defaultHeader]
             andURLParameters:urlParameters
        andHTTPBodyParameters:nil
                      success:success 
                      failure:failure];
}

- (void)postPath:(NSString *)path URLParameters:(NSDictionary *)urlParameters
                             HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                                        success:(CRRequestOperationSuccessBlock)success
                                        failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path
                   withMethod:CRRequestMethodPOST
                       header:[self defaultHeader]
             andURLParameters:urlParameters
        andHTTPBodyParameters:httpBodyParameters
                      success:success 
                      failure:failure];
}


- (void)deletePath:(NSString *)path 
        URLParameters:(NSDictionary *)urlParameters
           success:(CRRequestOperationSuccessBlock)success
           failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path 
                   withMethod:CRRequestMethodDELETE
                       header:[self defaultHeader]
             andURLParameters:urlParameters
        andHTTPBodyParameters:nil
                      success:success 
                      failure:failure];
}

#pragma mark - Image

- (void)loadImageAtURL:(NSURL *)imageURL 
             cacheName:(NSString *)cacheName 
               success:(CRRequestOperationSuccessBlock)success 
               failure:(CRRequestOperationFailureBlock)failure {
    
}

#pragma mark - Header

- (void)setBasicAuthUsername:(NSString *)username andPassword:(NSString *)password {
    NSString *authHeader = [NSString stringWithFormat:@"%@:%@", username, password];
    NSString *encodedAuthHeader = [[NSData dataWithBytes:[authHeader UTF8String] 
                                                  length:[authHeader length]] base64EncodedString];
    
    [self.defaultHeader setValue:[NSString stringWithFormat:@"Basic %@", encodedAuthHeader] 
                          forKey:@"Authorization"];
}

- (NSMutableDictionary *)defaultHeader {
    if (defaultHeader) return defaultHeader;
    
    defaultHeader = [[NSMutableDictionary alloc] init];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[defaultHeader setValue:@"application/json" forKey:@"Accept"];
    
	// Accept-Encoding HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.3
    [defaultHeader setValue:@"gzip" forKey:@"Accept-Encoding"];
    
	// Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
	NSString *preferredLanguageCodes = [[NSLocale preferredLanguages] componentsJoinedByString:@", "];
    [defaultHeader setValue:[NSString stringWithFormat:@"%@, en-us;q=0.8", preferredLanguageCodes] forKey:@"Accept-Language"];
	
	// User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
	//[self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@, Scale/%f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)]];
        
    return defaultHeader;
}

#pragma mark - Cookies

- (void)deleteCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:cookie];
    }
}


@end
