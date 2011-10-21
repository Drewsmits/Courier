//
//  CRResponse.h
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
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
}

@property (nonatomic, retain) NSURLResponse *response;

+ (CRResponse *)responseWithResponse:(NSURLResponse *)response;

- (NSInteger)statusCode;
- (NSString *)statusCodeDescription;

@end
