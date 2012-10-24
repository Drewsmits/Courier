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
#import "NSString+Courier.h"

@interface CRRequest ()
@property (nonatomic, assign) CRRequestMethod method;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSMutableDictionary *defaultHeader;
@property (nonatomic, strong) NSMutableDictionary *URLParameters;
@property (nonatomic, strong) NSMutableDictionary *HTTPBodyParameters;
@property (nonatomic, assign) BOOL shouldHandleCookies;
@end

@implementation CRRequest

+ (CRRequest *)requestWithMethod:(CRRequestMethod)method
                         forPath:(NSString *)path
               withURLParameters:(NSDictionary *)urlParameters
           andHTTPBodyParameters:(NSDictionary *)httpBodyParameters
                       andHeader:(NSDictionary *)header
             shouldHandleCookies:(BOOL)handleCookies
{    
	CRRequest *request = [CRRequest new];
    
    request.method              = method;
    request.path                = path;
    request.URLParameters       = [urlParameters mutableCopy];
    request.HTTPBodyParameters  = [httpBodyParameters mutableCopy];
    request.defaultHeader       = [header mutableCopy];
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
	[request setAllHTTPHeaderFields:[self header]];
    [request setTimeoutInterval:60.0];

    return  request;
}

- (NSString *)URLQueryString
{
    NSMutableArray *mutableParameterComponents = [NSMutableArray array];
    
    for (id parameter in self.URLParameters) {
        NSString *component = [NSString stringWithFormat:@"%@=%@", [[parameter description] urlEncodedStringWithEncoding:NSUTF8StringEncoding], 
                               [[[self.URLParameters valueForKey:parameter] description] urlEncodedStringWithEncoding:NSUTF8StringEncoding]];
        
        [mutableParameterComponents addObject:component];
    }
    
    NSString *str = [mutableParameterComponents componentsJoinedByString:@"&"];
    return str;
}

- (NSURL *)requestURL
{
    if (self.method == CRRequestMethodGET && self.URLParameters.count > 0) {
        NSString *stringToAppend = [self.path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@";
        return [NSURL URLWithString:[self.path stringByAppendingFormat:stringToAppend, [self URLQueryString]]];
    } else {
        return [NSURL URLWithString:self.path];
    }
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

- (NSDictionary *)header
{        
    if ((self.URLParameters || self.HTTPBodyParameters) && self.method != CRRequestMethodGET) {
        NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        [self.defaultHeader setObject:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forKey:@"Content-Type"];
    }

    return self.defaultHeader;
}

- (NSData *)HTTPBodyData
{    
    if (self.HTTPBodyParameters.count == 0) return nil;
    
    NSMutableArray *mutableParameterComponents = [NSMutableArray array];
    
    for (id parameter in self.HTTPBodyParameters) {
        
        NSString *encodedKey = [[parameter description] urlEncodedStringWithEncoding:NSUTF8StringEncoding];
        NSString *encodedValue = [[[self.HTTPBodyParameters valueForKey:parameter] description] urlEncodedStringWithEncoding:NSUTF8StringEncoding];
        
        NSString *component = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        
        [mutableParameterComponents addObject:component];
    }
    
    NSString *andJoinedString = [mutableParameterComponents componentsJoinedByString:@"&"];

    return [andJoinedString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
