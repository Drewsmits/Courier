//
//  Courier.m
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import "Courier.h"
#import "NSData+Courier.h"


@implementation Courier

//- (void)dealloc {    
//    [super dealloc];
//}

- (void)addOperationForPath:(NSString *)path 
                 withMethod:(CRRequestMethod)method
              andParameters:(NSDictionary *)parameters
                    success:(CRRequestOperationSuccessBlock)success 
                    failure:(CRRequestOperationFailureBlock)failure {
    
    
    CRRequest *request = [CRRequest requestWithMethod:method 
                                              forPath:path 
                                       withParameters:parameters
                                            andHeader:[self defaultHeader]];
    
    CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request
                                                                     success:success
                                                                     failure:failure];
    
    [self addOperation:operation];
}

- (void)getPath:(NSString *)path 
     parameters:(NSDictionary *)parameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path 
                   withMethod:CRRequestMethodGET
                andParameters:parameters
                      success:success 
                      failure:failure];
}

- (void)putPath:(NSString *)path 
     parameters:(NSDictionary *)parameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path 
                   withMethod:CRRequestMethodPUT
                andParameters:parameters
                      success:success 
                      failure:failure];
}

- (void)postPath:(NSString *)path 
      parameters:(NSDictionary *)parameters
         success:(CRRequestOperationSuccessBlock)success
         failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path
                   withMethod:CRRequestMethodPOST
                andParameters:parameters
                      success:success 
                      failure:failure];
}

- (void)deletePath:(NSString *)path 
        parameters:(NSDictionary *)parameters
           success:(CRRequestOperationSuccessBlock)success
           failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path 
                   withMethod:CRRequestMethodDELETE
                andParameters:parameters
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
