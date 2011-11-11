//
//  CRResponse.h
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
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

@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, assign) NSInteger dataCapacity;
@property (nonatomic, readonly) NSMutableData *data;
@property (nonatomic, readonly) BOOL success;

+ (id)responseWithResponse:(NSURLResponse *)response 
               andCapacity:(NSInteger)capacity;

- (NSInteger)statusCode;
- (NSString *)statusCodeDescription;

@end
