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
@property (readwrite, nonatomic, retain) NSDictionary *parameters;
@end

@implementation CRRequest

@synthesize method, path, parameters, httpBody, defaultHeader;

+ (CRRequest *)requestWithMethod:(CRRequestMethod)method
                         forPath:(NSString *)path
                  withParameters:(NSDictionary *)parameters
                     andHTTPBody:(NSMutableData *)bodyData
                       andHeader:(NSDictionary *)header {
    
	CRRequest *request = [[[CRRequest alloc] init] autorelease];
    
    request.method = method;
    request.path = path;
    request.parameters = parameters;
    request.httpBody = bodyData;
    request.defaultHeader = [header mutableCopy];
    
	return request;
}

- (NSMutableURLRequest *)URLRequest {
    
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    if (self.parameters && self.method != CRRequestMethodGET) {
        [request setHTTPBody:[self.queryString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
	[request setURL:self.requestURL];
	[request setHTTPMethod:self.requestMethodString];
    [request setHTTPBody:[NSData dataWithData:self.httpBody]];
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
