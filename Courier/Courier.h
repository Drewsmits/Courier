//
//  Courier.h
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
#import <Conductor/Conductor.h>

#import "CRRequest.h"
#import "CRRequestOperation.h"

@interface Courier : Conductor {}

/**
 Default headers used for every request
 */
@property (nonatomic, readonly) NSMutableDictionary *defaultHeader;

/**
 Route on which all API requests are relative to
 */
@property (nonatomic, copy) NSString *baseAPIPath;

/**
 Determines whether or not the Courier instance should handle cookies using the
 default NSHTTPCookieStorage
 */
@property (nonatomic, assign) BOOL shouldHandleCookies;

+ (Courier *)newCourierWithBaseAPIPath:(NSString *)baseAPIPat;

/**
 Add the username and password to the Basic Auth header in the default header.
 Username and password are encrypted.
 */
- (void)setBasicAuthUsername:(NSString *)username 
                 andPassword:(NSString *)password;

- (CDOperation *)addOperationForPath:(NSString *)path 
                          withMethod:(CRRequestMethod)method
                              header:(NSDictionary *)header
                    andURLParameters:(NSDictionary *)parameters
               andHTTPBodyParameters:(NSDictionary *)httpBodyParameters
                        toQueueNamed:(NSString *)queueName
                             success:(CRRequestOperationSuccessBlock)success 
                             failure:(CRRequestOperationFailureBlock)failure;

- (CDOperation *)putPath:(NSString *)path 
           URLParameters:(NSDictionary *)urlParameters
                 success:(CRRequestOperationSuccessBlock)success
                 failure:(CRRequestOperationFailureBlock)failure;

- (CDOperation *)deletePath:(NSString *)path 
              URLParameters:(NSDictionary *)urlParameters
                    success:(CRRequestOperationSuccessBlock)success
                    failure:(CRRequestOperationFailureBlock)failure;

- (void)deleteCookies;

- (BOOL)isBaseAPIPathReachable;

- (BOOL)isPathReachable:(NSString *)path 
       unreachableBlock:(CRRequestOperationFailureBlock)unreachableBlock;

@end
