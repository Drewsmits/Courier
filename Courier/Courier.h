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
#import "Conductor/Conductor.h"

#import "CRRequest.h"
#import "CRRequestOperation.h"

@interface Courier : Conductor {
@private
    NSMutableDictionary *defaultHeader;
    NSString *baseAPIPath;
}

/**
 Default headers used for every request
 */
@property (nonatomic, readonly) NSMutableDictionary *defaultHeader;

/**
 Route on which all API requests are relative to
 */
@property (nonatomic, retain) NSString *baseAPIPath;

/**
 Add the username and password to the Basic Auth header in the default header.
 Username and password are encrypted.
 */
- (void)setBasicAuthUsername:(NSString *)username 
                 andPassword:(NSString *)password;

- (void)getPath:(NSString *)path 
  URLParameters:(NSDictionary *)urlParameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure;

- (void)putPath:(NSString *)path 
  URLParameters:(NSDictionary *)urlParameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure;

- (void)postPath:(NSString *)path 
   URLParameters:(NSDictionary *)urlParameters
         success:(CRRequestOperationSuccessBlock)success
         failure:(CRRequestOperationFailureBlock)failure;

- (void)postPath:(NSString *)path URLParameters:(NSDictionary *)urlParameters
                             HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                                        success:(CRRequestOperationSuccessBlock)success
                                        failure:(CRRequestOperationFailureBlock)failure;

- (void)deletePath:(NSString *)path 
     URLParameters:(NSDictionary *)urlParameters
           success:(CRRequestOperationSuccessBlock)success
           failure:(CRRequestOperationFailureBlock)failure;

@end
