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
@property (readwrite, nonatomic, copy) NSString *path;
@property (readwrite, nonatomic, retain) NSDictionary *defaultHeader;
@property (readwrite, nonatomic, retain) NSDictionary *URLParameters;
@property (readwrite, nonatomic, retain) NSDictionary *HTTPBodyParameters;
@end

@implementation CRRequest

@synthesize method, path, URLParameters, HTTPBodyParameters, defaultHeader;

+ (CRRequest *)requestWithMethod:(CRRequestMethod)method
                         forPath:(NSString *)path
               withURLParameters:(NSDictionary *)urlParameters
           andHTTPBodyParameters:(NSDictionary *)httpBodyParameters
                       andHeader:(NSDictionary *)header {
    
	CRRequest *request = [[[CRRequest alloc] init] autorelease];
    
    request.method = method;
    request.path = path;
    request.URLParameters = urlParameters;
    request.HTTPBodyParameters = httpBodyParameters;
    request.defaultHeader = [header mutableCopy];
    
	return request;
}

#pragma mark - Accessors

- (NSMutableURLRequest *)URLRequest {
    
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
	[request setURL:self.requestURL];
	[request setHTTPMethod:self.requestMethodString];
    [request setHTTPBody:[self HTTPBodyData]];
	[request setHTTPShouldHandleCookies:NO];
	[request setAllHTTPHeaderFields:[self header]];

    return  request;
}

- (NSString *)URLQueryString {
    NSMutableArray *mutableParameterComponents = [NSMutableArray array];
    
    for (id parameter in self.URLParameters) {
        NSString *component = [NSString stringWithFormat:@"%@=%@", [[parameter description] urlEncodedStringWithEncoding:NSUTF8StringEncoding], 
                               [[[self.URLParameters valueForKey:parameter] description] urlEncodedStringWithEncoding:NSUTF8StringEncoding]];
        
        [mutableParameterComponents addObject:component];
    }
    
    NSString *str = [mutableParameterComponents componentsJoinedByString:@"&"];
    return str;
}

- (NSURL *)requestURL {
    if (self.method == CRRequestMethodGET) {
        NSString *stringToAppend = [self.path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@";
        return [NSURL URLWithString:[self.path stringByAppendingFormat:stringToAppend, [self URLQueryString]]];
    } else {
        return [NSURL URLWithString:self.path];
    }
}

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
    
    if ((self.URLParameters || self.HTTPBodyParameters) && self.method != CRRequestMethodGET) {
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        [dict setObject:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forKey:@"Content-Type"];
       
//        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSASCIIStringEncoding));
//        [dict setObject:[NSString stringWithFormat:@"audio/x-wav; charset=%@", charset] forKey:@"Content-Type"];
    }

    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSData *)HTTPBodyData {
    
    NSMutableArray *mutableParameterComponents = [NSMutableArray array];
    
    for (id parameter in self.HTTPBodyParameters) {
        NSString *component = [NSString stringWithFormat:@"%@=%@", [parameter description], 
                               [[self.HTTPBodyParameters valueForKey:parameter] description]];
        
        [mutableParameterComponents addObject:component];
    }
    
    NSString *andJoinedString = [mutableParameterComponents componentsJoinedByString:@"&"];

    return [andJoinedString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
