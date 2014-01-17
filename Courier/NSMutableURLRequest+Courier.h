//
//  NSMutableURLRequest+Courier.h
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

#import <Foundation/Foundation.h>

typedef enum {
  CR_URLRequestEncodingUnknown,
  CR_URLFormURLParameterEncoding,
  CR_URLJSONParameterEncoding,
} CR_URLRequestEncoding;

@interface NSMutableURLRequest (Courier)

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path;

/**
 
 @note This will set the Content-Type header to the appropriate type, unless you
 specify your own.
 
 */
+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                  encoding:(CR_URLRequestEncoding)encoding
                             URLParameters:(NSDictionary *)urlParameters
                        HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                                    header:(NSDictionary *)header;

@end
