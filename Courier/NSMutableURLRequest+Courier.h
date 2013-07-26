//
//  NSMutableURLRequest+Courier.h
//  Courier
//
//  Created by Andrew Smith on 7/25/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  CR_URLRequestEncodingUnknown,
  CR_URLFormURLParameterEncoding,
  CR_URLJSONParameterEncoding,
} CR_URLRequestEncoding;

@interface NSMutableURLRequest (Courier)

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                  encoding:(CR_URLRequestEncoding)encoding
                             URLParameters:(NSDictionary *)urlParameters
                        HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                                    header:(NSDictionary *)header
                       shouldHandleCookies:(BOOL)handleCookies;

@end
