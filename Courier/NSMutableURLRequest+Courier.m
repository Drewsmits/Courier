//
//  NSMutableURLRequest+Courier.m
//  Courier
//
//  Created by Andrew Smith on 7/25/13.
//  Copyright (c) 2013 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
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
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSMutableURLRequest+Courier.h"

#import "NSDictionary+Courier.h"

@implementation NSMutableURLRequest (Courier)

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
{
    return [self requestWithMethod:method
                              path:path
                          encoding:CR_URLRequestEncodingUnknown
                     URLParameters:nil
                HTTPBodyParameters:nil
                            header:nil];
}

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                  encoding:(CR_URLRequestEncoding)encoding
                             URLParameters:(NSDictionary *)urlParameters
                        HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                                    header:(NSDictionary *)header
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURLPath:path withParameters:urlParameters];
    [request setHTTPMethod:method];
    [request setHTTPBodyDataWithParameters:httpBodyParameters encoding:encoding];
    [request setAllHTTPHeaderFields:header];
    [request addHeaderContentTypeForEncoding:encoding];
    
    return request;
}

#pragma mark - URL

- (void)setURLPath:(NSString *)path
    withParameters:(NSDictionary *)parameters
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
    // Set the content type
    //
    if (encoding == CR_URLFormURLParameterEncoding) {
        // Form URL
        NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        NSString *type = [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset];
        [self addValue:type forHTTPHeaderField:@"Content-Type"];
    } else if (encoding == CR_URLJSONParameterEncoding) {
        // JSON
        [self addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
}

#pragma mark - Body

- (void)setHTTPBodyDataWithParameters:(NSDictionary *)parameters
                             encoding:(CR_URLRequestEncoding)encoding
{
    if (!parameters) return;
    
    NSData *bodyData = nil;
    
    if (encoding == CR_URLFormURLParameterEncoding) {
        // Form URL
        bodyData = [parameters asFormURLEncodedData];
    } else if (encoding == CR_URLJSONParameterEncoding) {
        // JSON
        bodyData = [parameters asJSONData];
    } else {
        // Unknown encoding. Pass it through.
        bodyData = [NSKeyedArchiver archivedDataWithRootObject:parameters];
    }
    
    [self setHTTPBody:bodyData];
}

@end
