//
//  NSURLResponseCourierTests.m
//  Courier
//
//  Created by Andrew Smith on 1/13/14.
//  Copyright (c) 2014 Andrew B. Smith. All rights reserved.
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
