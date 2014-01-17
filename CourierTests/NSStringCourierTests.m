//
//  NSStringCourierTests.m
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

#import "NSString+Courier.h"

@interface NSStringCourierTests : CRTestCase

@end

@implementation NSStringCourierTests

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

- (void)testURLEncodedString
{
    //
    // :/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`
    //
    XCTAssertEqualObjects([@":" urlEncodedString]  , @"%3A", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"/" urlEncodedString]  , @"%2F", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"?" urlEncodedString]  , @"%3F", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"#" urlEncodedString]  , @"%23", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"[" urlEncodedString]  , @"%5B", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"]" urlEncodedString]  , @"%5D", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"@" urlEncodedString]  , @"%40", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"!" urlEncodedString]  , @"%21", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"$" urlEncodedString]  , @"%24", @"Should be encoded correctly");
    XCTAssertEqualObjects([@" " urlEncodedString]  , @"%20", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"&" urlEncodedString]  , @"%26", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"'" urlEncodedString]  , @"%27", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"(" urlEncodedString]  , @"%28", @"Should be encoded correctly");
    XCTAssertEqualObjects([@")" urlEncodedString]  , @"%29", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"*" urlEncodedString]  , @"%2A", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"+" urlEncodedString]  , @"%2B", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"," urlEncodedString]  , @"%2C", @"Should be encoded correctly");
    XCTAssertEqualObjects([@";" urlEncodedString]  , @"%3B", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"=" urlEncodedString]  , @"%3D", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"\"" urlEncodedString] , @"%22", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"<" urlEncodedString]  , @"%3C", @"Should be encoded correctly");
    XCTAssertEqualObjects([@">" urlEncodedString]  , @"%3E", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"%" urlEncodedString]  , @"%25", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"{" urlEncodedString]  , @"%7B", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"}" urlEncodedString]  , @"%7D", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"|" urlEncodedString]  , @"%7C", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"\\" urlEncodedString] , @"%5C", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"^" urlEncodedString]  , @"%5E", @"Should be encoded correctly");
    XCTAssertEqualObjects([@"~" urlEncodedString]  , @"%7E", @"Should be encoded correctly");
}

@end
