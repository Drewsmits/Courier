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

@synthesize baseAPIPath;

+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)dealloc {
    [defaultHeader release], defaultHeader = nil;
    [baseAPIPath release], baseAPIPath = nil;
    
    [super dealloc];
}

+ (Courier *)courier {
    return [[[self alloc] init] autorelease];
}

#pragma mark - API

- (void)addOperationForPath:(NSString *)path 
                 withMethod:(CRRequestMethod)method
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
                                            andHeader:[self defaultHeader]
                                  shouldHandleCookies:NO];
    
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
             andURLParameters:urlParameters
        andHTTPBodyParameters:nil
                      success:success 
                      failure:failure];
}

#pragma mark - Header

- (void)setBasicAuthUsername:(NSString *)username andPassword:(NSString *)password {
    NSString *authHeader = [NSString stringWithFormat:@"%@:%@", username, password];
    NSString *encodedAuthHeader = [[NSData dataWithBytes:[authHeader UTF8String] 
                                                  length:[authHeader length]] base64EncodedString];
    
    [self.defaultHeader setValue:[NSString stringWithFormat:@"Basic %@", encodedAuthHeader] 
                          forKey:@"Authorization"];
}

- (NSDictionary *)defaultHeader {
    if (defaultHeader) return [[defaultHeader retain] autorelease];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[dict setValue:@"application/json" forKey:@"Accept"];
    
	// Accept-Encoding HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.3
    [dict setValue:@"gzip" forKey:@"Accept-Encoding"];
    
	// Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
	NSString *preferredLanguageCodes = [[NSLocale preferredLanguages] componentsJoinedByString:@", "];
    [dict setValue:[NSString stringWithFormat:@"%@, en-us;q=0.8", preferredLanguageCodes] forKey:@"Accept-Language"];
	
	// User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
	//[self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@, Scale/%f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)]];
    
    defaultHeader = [dict retain];
    
    return [[defaultHeader retain] autorelease];
}


@end
