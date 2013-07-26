//
//  NSMutableURLRequest+Courier.m
//  Courier
//
//  Created by Andrew Smith on 7/25/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "NSMutableURLRequest+Courier.h"

#import "NSDictionary+Courier.h"

@implementation NSMutableURLRequest (Courier)

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                  encoding:(CR_URLRequestEncoding)encoding
                             URLParameters:(NSDictionary *)urlParameters
                        HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                                    header:(NSDictionary *)header
                       shouldHandleCookies:(BOOL)handleCookies
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURLPath:path withParameters:urlParameters];
    [request setHTTPMethod:method];
    [request setHTTPBodyDataWithParameters:httpBodyParameters encoding:encoding];
    [request setHTTPShouldHandleCookies:handleCookies];
    [request setAllHTTPHeaderFields:header];
    [request addHeaderContentTypeForEncoding:encoding];
    
    return request;
}

#pragma mark - URL

- (void)setURLPath:(NSString *)path withParameters:(NSDictionary *)parameters
{
    //
    // Append path with URL params, if present
    //
    if (parameters.count > 0) {
      NSString *stringToAppend = [path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@";
      NSString *newPath = [path stringByAppendingFormat:stringToAppend, [parameters asFormURLEncodedString]];
      path = newPath;
    }

    self.URL = [NSURL URLWithString:path];
}

#pragma mark - Header

- (void)addHeaderContentTypeForEncoding:(CR_URLRequestEncoding)encoding
{
    //
    // Bail if content type is already set
    //
    if (self.allHTTPHeaderFields[@"Content-Type"]) return;
    
    //
    // Form URL encoding
    //
    if (encoding == CR_URLFormURLParameterEncoding) {
      NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
      NSString *type = [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset];
      [self addValue:type forHTTPHeaderField:@"Content-Type"];
    }
    
    //
    // JSON encoding
    //
    if (encoding == CR_URLJSONParameterEncoding) {
      [self addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
}

#pragma mark - Body

- (void)setHTTPBodyDataWithParameters:(NSDictionary *)parameters
                             encoding:(CR_URLRequestEncoding)encoding
{
    NSData *bodyData;
    
    //
    // Form URL encoding
    //
    if (encoding == CR_URLFormURLParameterEncoding) {
      bodyData = [parameters asFormURLEncodedData];
    }
    
    //
    // JSON encoding
    //
    if (encoding == CR_URLJSONParameterEncoding) {
      bodyData = [parameters asJSONData];
    }
    
    [self setHTTPBody:bodyData];
}

@end
