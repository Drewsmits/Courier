//
//  CRResponse.m
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import "CRResponse.h"

@implementation CRResponse

@synthesize response,
            dataCapacity;

- (void)dealloc {
    [response release];
    [data release];
    
    [super dealloc];
}

+ (id)responseWithResponse:(NSURLResponse *)response 
               andCapacity:(NSInteger)capacity {
    
    CRResponse *rep = [[[self alloc] init] autorelease];
    
    rep.response = response;
    rep.dataCapacity = capacity;
    
    return rep;
}

- (NSInteger)statusCode {
    return [(NSHTTPURLResponse *)self.response statusCode];
}

- (NSString *)statusCodeDescription {
    switch (self.statusCode) {
        case HTTPResponseStatusCodeOK:
            return @"200 OK";
            break;
        case HTTPResponseStatusCodeCreated:
            return @"201 Created. The request has been fulfilled and resulted in a new resource being created.";
            break;
        case HTTPResponseStatusCodeAccepted:
            return @"202 Accepted. The server has accepted the request, but hasn't yet processed it.";
            break;
        case HTTPResponseStatusCodeNonAuthoritativeInformation:
            return @"203 Non-Authoritative Information. The server successfully processed the request, but is returning information that may be from another source..";
            break;
        case HTTPResponseStatusCodeNoContent:
            return @"204 No content. The server successfully processed the request, but is not returning any content.";
            break;
        case HTTPResponseStatusCodeResetContent:
            return @"205 Reset content. The server successfully proccessed the request, but isn't returning any content. Unlike a 204 response, this response requires that the requestor reset the document view (for instance, clear a form for new input).";
            break;
        case HTTPResponseStatusCodePartialContent:
            return @"206 Partial content. The server successfully processed a partial GET request.";  
            break;
        case HTTPResponseStatusCodeBadRequest:
            return @"400 Bad request. The server didn't understand the syntax of the request.";
            break;
        case HTTPResponseStatusCodeNotAuthorized:
            return @"401 Not authorized. The request requires authentication.";
            break;
        case HTTPResponseStatusCodeForbidden:
            return @"403 Forbidden. The server is refusing the request.";
            break;
        case HTTPResponseStatusCodeNotFound:
            return @"404 Not found.  The server can't find the requested resource.";
            break;
        case HTTPResponseStatusCodeInternalServerError:
            return @"500 Internal Server Error. The server encountered an unexpected condition which prevented it from fulfilling the request.";
            break;
        default:
            return [NSString stringWithFormat:@"Unknown status code: %d", self.statusCode];
            break;
    }
}

- (BOOL)success {
    
    if (self.statusCode > 100 && self.statusCode < 300) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Accessors

- (NSMutableData *)data {
    if (data) return [[data retain] autorelease];
    data = [[NSMutableData alloc] initWithCapacity:self.dataCapacity];
    return [[data retain] autorelease];
}

@end
