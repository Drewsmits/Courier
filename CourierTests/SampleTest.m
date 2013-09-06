//
//  SampleTest.m
//  Courier
//
//  Created by Andrew Smith on 8/17/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SampleTest : XCTestCase

@end

@implementation SampleTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
