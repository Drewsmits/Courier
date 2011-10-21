//
//  Courier.m
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import "Courier.h"

#import "NSData+Courier.h"

@interface Courier ()
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@end

@implementation Courier

@synthesize operationQueue;

- (void)dealloc {
    [operationQueue release];
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
        NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
        [queue setMaxConcurrentOperationCount:1];
        self.operationQueue = queue;
        
    }
    return self;
}

+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)getPath:(NSString *)path 
     parameters:(NSDictionary *)parameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure {
    
    CRRequest *request = [CRRequest requestWithMethod:CRRequestMethodGET 
                                              forPath:path 
                                       withParameters:parameters
                                            andHeader:[self defaultHeader]];
        
    CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request
                                                                     success:success
                                                                     failure:failure];
    
    [self.operationQueue addOperation:operation];
    
}

- (NSDictionary *)defaultHeader {
    
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
    
    NSString *authHeader = [NSString stringWithFormat:@"%@:%@", @"drewsmits@gmail.com", @"dogscreenredchair"];
    NSString *encodedAuthHeader = [[NSData dataWithBytes:[authHeader UTF8String] length:[authHeader length]] base64EncodedString];
    [dict setValue:[NSString stringWithFormat:@"Basic %@", encodedAuthHeader] forKey:@"Authorization"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}


@end
