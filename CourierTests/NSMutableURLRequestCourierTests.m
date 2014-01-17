//
//  NSMutableURLRequestCourierTests.m
//  Courier
//
//  Created by Andrew Smith on 1/13/14.
//  Copyright (c) 2014 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
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
//

#import "CRTestCase.h"

#import "NSMutableURLRequest+Courier.h"
#import "NSDictionary+Courier.h"

// Declare private methods as public for tests
@interface NSMutableURLRequest (CourierTests)
- (void)setURLPath:(NSString *)path withParameters:(NSDictionary *)parameters;
- (void)addHeaderContentTypeForEncoding:(CR_URLRequestEncoding)encoding;
- (void)setHTTPBodyDataWithParameters:(NSDictionary *)parameters encoding:(CR_URLRequestEncoding)encoding;
@end

@interface NSMutableURLRequestCourierTests : CRTestCase

@end

@implementation NSMutableURLRequestCourierTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

#pragma mark - Initialization

- (void)testRequestWithMethodPartial
{
    NSString *path = @"http://business.com/api/v1?param=value";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"GET"
                                                                     path:path];
    
    XCTAssertNotNil(request.URL, @"Request should have a URL");
    XCTAssertEqualObjects(request.HTTPMethod, @"GET", @"Request should have the correct HTTPmethod");
    XCTAssertNil(request.HTTPBody, @"Request should have HTTPBody data");
}

- (void)testRequestWithMethodFull
{
    NSString *path = @"http://business.com/api/v1?param=value";
    NSDictionary *urlParams = @{@"key1" : @"value1", @"key2" : @"value2"};
    NSDictionary *bodyParams = @{@"key1" : @"value1", @"key2" : @"value2"};
    NSDictionary *header = @{@"Header-Key" : @"Value"};
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"GET"
                                                                     path:path
                                                                 encoding:CR_URLJSONParameterEncoding
                                                            URLParameters:urlParams
                                                       HTTPBodyParameters:bodyParams
                                                                   header:header];
    
    XCTAssertNotNil(request.URL, @"Request should have a URL");
    XCTAssertEqualObjects(request.HTTPMethod, @"GET", @"Request should have the correct HTTPmethod");
    XCTAssertNotNil(request.HTTPBody, @"Request should have HTTPBody data");
    
    NSMutableDictionary *expectedHeader = [NSMutableDictionary dictionary];
    [expectedHeader addEntriesFromDictionary:header];
    expectedHeader[@"Content-Type"] = @"application/json";
    
    XCTAssertEqualObjects(request.allHTTPHeaderFields, expectedHeader, @"Request should have the correct header");
}

#pragma mark - setURLPath:withParameters:

- (void)testSetURLWithNoParams
{
    NSString *path = @"http://business.com/api/v1";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURLPath:path withParameters:nil];
    
    XCTAssertEqualObjects(request.URL,
                          [NSURL URLWithString:path],
                          @"Request should have the correct URL");
}

- (void)testSetURLPathWithParameters
{
    NSString *path = @"http://business.com/api/v1";
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURLPath:path withParameters:params];
    
    NSString *expectedPath = [NSString stringWithFormat:@"%@%@", path, @"?key2=value2&key1=value1"];
    
    XCTAssertEqualObjects(request.URL,
                          [NSURL URLWithString:expectedPath],
                          @"Request should have the correct URL");
    
}

- (void)testSetURLPathWithParametersAlreadInPath
{
    NSString *path = @"http://business.com/api/v1?param=value";
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURLPath:path withParameters:params];
    
    NSString *expectedPath = [NSString stringWithFormat:@"%@%@", path, @"&key2=value2&key1=value1"];
    
    XCTAssertEqualObjects(request.URL,
                          [NSURL URLWithString:expectedPath],
                          @"Request should have the correct URL");
}

#pragma mark - addHeaderContentTypeForEncoding

- (void)testAddHeaderContentTypeWhenAlreadySet
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request addValue:@"application/custom-content-type" forHTTPHeaderField:@"Content-Type"];
    
    [request addHeaderContentTypeForEncoding:CR_URLFormURLParameterEncoding];
    
    XCTAssertEqualObjects(request.allHTTPHeaderFields[@"Content-Type"],
                          @"application/custom-content-type",
                          @"Should not override existing content type");
}

- (void)testAddHeaderContentTypeForEncodingUnknown
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [request addHeaderContentTypeForEncoding:CR_URLRequestEncodingUnknown];
    
    XCTAssertNil(request.allHTTPHeaderFields[@"Content-Type"],
                 @"Request should not have a Content-Type header");
}

- (void)testAddHeaderContentTypeForEncodingFormURL
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request addHeaderContentTypeForEncoding:CR_URLFormURLParameterEncoding];
    
    XCTAssertEqualObjects(request.allHTTPHeaderFields[@"Content-Type"],
                          @"application/x-www-form-urlencoded; charset=utf-8",
                          @"Request should have correct content type");
}

- (void)testAddHeaderContentTypeForEncodingJSON
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request addHeaderContentTypeForEncoding:CR_URLJSONParameterEncoding];
    
    XCTAssertEqualObjects(request.allHTTPHeaderFields[@"Content-Type"],
                          @"application/json",
                          @"Request should have correct content type");
}

#pragma mark - setHTTPBodyDataWithParameters:encoding:

- (void)testHTTPBodyDataWithParametersUnknownEncoding
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *path = @"http://business.com/api/v1?param=value";
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};
    
    [request setURLPath:path withParameters:params];
    
    [request setHTTPBodyDataWithParameters:params encoding:CR_URLRequestEncodingUnknown];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:params];
    
    XCTAssertEqualObjects(request.HTTPBody,
                          data,
                          @"Request should have the correct body data");
}

- (void)testHTTPBodyDataWithParametersFormURLEncoding
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *path = @"http://business.com/api/v1?param=value";
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};
    
    [request setURLPath:path withParameters:params];
    
    [request setHTTPBodyDataWithParameters:params encoding:CR_URLFormURLParameterEncoding];
    
    NSData *data = [params asFormURLEncodedData];
    
    XCTAssertEqualObjects(request.HTTPBody,
                          data,
                          @"Request should have the correct body data");
}

- (void)testHTTPBodyDataWithParametersJSONEncoding
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *path = @"http://business.com/api/v1?param=value";
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};
    
    [request setURLPath:path withParameters:params];
    
    [request setHTTPBodyDataWithParameters:params encoding:CR_URLJSONParameterEncoding];
    
    NSData *data = [params asJSONData];
    
    XCTAssertEqualObjects(request.HTTPBody,
                          data,
                          @"Request should have the correct body data");
}

@end
