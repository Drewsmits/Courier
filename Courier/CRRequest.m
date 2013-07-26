//
//  CRRequest.m
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

#import "CRRequest.h"
#import "NSDictionary+Courier.h"
#import "NSString+Courier.h"

@interface CRRequest ()
@property (nonatomic, assign) CRRequestMethod method;
@property (nonatomic, assign) CRRequestEncoding encoding;
@property (nonatomic, strong) NSMutableDictionary *URLParameters;
@property (nonatomic, strong) NSMutableDictionary *HTTPBodyParameters;
@property (nonatomic, assign) BOOL shouldHandleCookies;
@end

@implementation CRRequest

+ (CRRequest *)requestWithMethod:(CRRequestMethod)method
                            path:(NSString *)path
                        encoding:(CRRequestEncoding)encoding
                   URLParameters:(NSDictionary *)urlParameters
              HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                          header:(NSDictionary *)header
             shouldHandleCookies:(BOOL)handleCookies
{
    CRRequest *request = [CRRequest new];
    
    request.method              = method;
    request.path                = path;
    request.encoding            = encoding;
    request.URLParameters       = [urlParameters mutableCopy];
    request.HTTPBodyParameters  = [httpBodyParameters mutableCopy];
    request.header              = [header mutableCopy];
    request.shouldHandleCookies = handleCookies;
    
    return request;
}

#pragma mark - Accessors

- (NSMutableURLRequest *)URLRequest
{    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:self.requestURL];
    [request setHTTPMethod:self.requestMethodString];
    [request setHTTPBody:[self HTTPBodyData]];
    [request setHTTPShouldHandleCookies:self.shouldHandleCookies];
	
    // Content-Type
    [self setHeaderContentType];
    [request setAllHTTPHeaderFields:self.header];
    
    //
    // for POST requests only
    //
    [request setTimeoutInterval:60.0];

    return  request;
}

- (NSURL *)requestURL
{
    //
    // Append path with URL params, if present
    //
    if (self.URLParameters.count > 0) {
        NSString *stringToAppend = [self.path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@";
        NSString *newPath = [self.path stringByAppendingFormat:stringToAppend, [self.URLParameters asFormURLEncodedString]];
        self.path = newPath;
    }
    
    return [NSURL URLWithString:self.path];
}

- (NSString *)requestMethodString
{
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

- (void)setHeaderContentType
{ 
    //
    // Form URL encoding
    //
    if (self.encoding == CRFormURLParameterEncoding) {
        NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        NSString *type = [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset];
        self.header[@"Content-Type"] = type;
    }
    
    //
    // JSON encoding
    //
    if (self.encoding == CRJSONParameterEncoding) {
        self.header[@"Content-Type"] = @"application/json";
    }
}

- (NSData *)HTTPBodyData
{    
    if (self.HTTPBodyParameters.count == 0) return nil;
    
    //
    // Form URL encoding
    //
    if (self.encoding == CRFormURLParameterEncoding) {
        return [self.HTTPBodyParameters asFormURLEncodedData];
    }
    
    //
    // JSON encoding
    //
    if (self.encoding == CRJSONParameterEncoding) {
        return [self.HTTPBodyParameters asJSONData];
    }
    
    return nil;
}

@end
