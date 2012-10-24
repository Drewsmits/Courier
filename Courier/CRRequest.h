//
//  CRRequest.h
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

#import <Foundation/Foundation.h>

typedef enum {
    CRRequestMethodGET,
    CRRequestMethodPUT,
    CRRequestMethodPOST,
    CRRequestMethodDELETE,
}CRRequestMethod;

@interface CRRequest : NSObject {}

/**
 Enum of the request method
 */
@property (nonatomic, assign, readonly) CRRequestMethod method;

/**
 String representation of the request method
 */
@property (nonatomic, strong, readonly) NSString *requestMethodString;

/**
 The path to the network resource
 */
@property (nonatomic, copy, readonly) NSString *path;

/**
 Parameters to add to the request URL.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *URLParameters;

/**
 Parameters to insert in into the HTTP body
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *HTTPBodyParameters;

/**
 Default header for the request
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *defaultHeader;

/**
 Determines if the request should handle cookies
 */
@property (nonatomic, assign, readonly) BOOL shouldHandleCookies;

/**
 Factory method for building the CRRequest
 
 @param
 @param
 @param
 @param
 @param
 
 */
+ (CRRequest *)requestWithMethod:(CRRequestMethod)method
                         forPath:(NSString *)path
               withURLParameters:(NSDictionary *)urlParameters
           andHTTPBodyParameters:(NSDictionary *)httpBodyParameters
                       andHeader:(NSDictionary *)header
             shouldHandleCookies:(BOOL)handleCookies;

/**
 Builds the request header
 */
- (NSDictionary *)header;

/**
 Builds the http body data from the HTTPBodyParameters
 */
- (NSData *)HTTPBodyData;

/**
 Builds the URL query string from the URLParameters
 */
- (NSString *)URLQueryString;

/**
 Builds the request URL from the passed in path
 */
- (NSURL *)requestURL;

/**
 Builds the URL request
 */
- (NSMutableURLRequest *)URLRequest;

@end
