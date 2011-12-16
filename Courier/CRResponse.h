//
//  CRResponse.h
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
    HTTPResponseStatusCodeOK = 200,
    HTTPResponseStatusCodeCreated,
    HTTPResponseStatusCodeAccepted,
    HTTPResponseStatusCodeNonAuthoritativeInformation,
    HTTPResponseStatusCodeNoContent,
    HTTPResponseStatusCodeResetContent,
    HTTPResponseStatusCodePartialContent,
    HTTPResponseStatusCodeBadRequest = 400,
    HTTPResponseStatusCodeNotAuthorized,
    HTTPResponseStatusCodeForbidden = 403,
    HTTPResponseStatusCodeNotFound,
    HTTPResponseStatusCodeMethodNotAllowed,
    HTTPResponseStatusCodeNotAcceptable,
    HTTPResponseStatusCodeProxyAuthRequired,
    HTTPResponseStatusCodeRequestTimeout,
    HTTPResponseStatusCodeConflict,
    HTTPResponseStatusCodeGone,
    HTTPResponseStatusCodeLengthRequired,
    HTTPResponseStatusCodePreconditionFailed,
    HTTPResponseStatusCodeRequestEntityTooLarge,
    HTTPResponseStatusCodeRequestedURIIsTooLong,
    HTTPResponseStatusCodeUnsupportedMediaType,
    HTTPResponseStatusCodeRequestRangeNotSatisfiable,
    HTTPResponseStatusExpectationFailed,
    HTTPResponseStatusCodeInternalServerError = 500,
    HTTPResponseStatusCodeNotImplemented,
    HTTPResponseStatusCodeBadGateway,
    HTTPResponseStatusCodeServiceUnavailable,
    HTTPResponseStatusCodeGatewayTimeout,
    HTTPResponseStatusCodeHTTPVersionNotSupported,
} HTTPResponseStatusCode;

@interface CRResponse : NSObject {
@private
    NSURLResponse *response;
    NSMutableData *data;
}

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, assign) NSInteger dataCapacity;
@property (weak, nonatomic, readonly) NSMutableData *data;
@property (nonatomic, readonly) BOOL success;

@property (weak, nonatomic, readonly) NSString *responseDescription;

+ (id)responseWithResponse:(NSURLResponse *)response 
               andCapacity:(NSInteger)capacity;

- (NSInteger)statusCode;
- (NSString *)statusCodeDescription;

@end
