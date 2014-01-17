//
//  NSURLResponseCourierTests.m
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

#import "NSURLResponse+Courier.h"

@interface NSURLResponseCourierTests : CRTestCase

@end

@implementation NSURLResponseCourierTests

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

- (void)testStatusCode
{
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"path"]
                                                          statusCode:200
                                                        HTTPVersion:@"HTTP/1.1"
                                                        headerFields:nil];
    
    XCTAssertEqual([response statusCode],
                   200,
                   @"Response shoudl have correct status code");
}

- (void)testSuccess
{
    NSURLResponse *success1 = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"path"]
                                                          statusCode:200
                                                         HTTPVersion:@"HTTP/1.1"
                                                        headerFields:nil];
    
    XCTAssertTrue(success1.success, @"Response should be a success");
    
    NSURLResponse *success2 = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"path"]
                                                          statusCode:201
                                                         HTTPVersion:@"HTTP/1.1"
                                                        headerFields:nil];
    
    XCTAssertTrue(success2.success, @"Response should be a success");
    
    NSURLResponse *fail1 = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"path"]
                                                          statusCode:400
                                                         HTTPVersion:@"HTTP/1.1"
                                                        headerFields:nil];
    
    XCTAssertFalse(fail1.success, @"Response should be a failure");
    
    NSURLResponse *fail2 = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"path"]
                                                          statusCode:100
                                                         HTTPVersion:@"HTTP/1.1"
                                                        headerFields:nil];
    
    XCTAssertFalse(fail2.success, @"Response should be a failure");
}

@end
