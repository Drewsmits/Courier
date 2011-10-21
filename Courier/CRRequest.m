//
//  CRRequest.m
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import "CRRequest.h"
#import "NSString+Courier.h"

@interface CRRequest ()
@property (readwrite, nonatomic, copy) NSString *path;
@property (readwrite, nonatomic, retain) NSDictionary *parameters;
@end

@implementation CRRequest

@synthesize method, path, parameters, defaultHeader;

+ (CRRequest *)requestWithMethod:(CRRequestMethod)method
                         forPath:(NSString *)path
                  withParameters:(NSDictionary *)parameters 
                       andHeader:(NSDictionary *)header {
    
	CRRequest *request = [[[CRRequest alloc] init] autorelease];
    
    request.method = method;
    request.path = path;
    request.parameters = parameters;
    request.defaultHeader = [header mutableCopy];
    
	return request;
}

- (NSURLRequest *)URLRequest {
    
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    if (self.parameters) {
        [request setHTTPBody:[self.queryString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
	[request setURL:self.requestURL];
	[request setHTTPMethod:self.requestMethodString];
	[request setHTTPShouldHandleCookies:NO];
	[request setAllHTTPHeaderFields:self.header];

    return  request;
}

- (NSString *)queryString {
    NSMutableArray *mutableParameterComponents = [NSMutableArray array];
    
    for (id parameter in self.parameters) {
        NSString *component = [NSString stringWithFormat:@"%@=%@", [[parameter description] urlEncodedStringWithEncoding:NSUTF8StringEncoding], 
                               [[[self.parameters valueForKey:parameter] description] urlEncodedStringWithEncoding:NSUTF8StringEncoding]];
        
        [mutableParameterComponents addObject:component];
    }
    
    NSString *str = [mutableParameterComponents componentsJoinedByString:@"&"];
    return str;
}

- (NSURL *)requestURL {
    if (self.method == CRRequestMethodGET) {
        NSString *stringToAppend = [self.path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@";
        return [NSURL URLWithString:[self.path stringByAppendingFormat:stringToAppend, self.queryString]];
    } else {
        return [NSURL URLWithString:self.path];
    }
}

#pragma mark - Accessors

- (NSString *)requestMethodString {
    switch (self.method) {
        case CRRequestMethodGET:
            return @"GET";
            break;
        case CRRequestMethodPUT:
            return @"PUT";
            break;
        case CRRequestMethodPOST:
            return @"POST";
            break;
        case CRRequestMethodDELETE:
            return @"DELETE";
            break;
        default:
            return nil;
            break;
    }
}

- (NSDictionary *)header {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.defaultHeader];
    
    if (self.parameters && self.method != CRRequestMethodGET) {
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        [dict setObject:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forKey:@"Content-Type"];
    }

    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
