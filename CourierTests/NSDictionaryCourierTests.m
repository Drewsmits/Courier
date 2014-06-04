//
//  NSDictionaryCourierTests.m
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

#import "NSDictionary+Courier.h"

@interface NSDictionaryCourierTests : CRTestCase

@end

@implementation NSDictionaryCourierTests

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

- (void)testAsJSONString
{
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};

    NSString *jsonParams = [params cou_asJSONString];
    
    XCTAssertEqualObjects(jsonParams,
                          @"{\"key1\":\"value1\",\"key2\":\"value2\"}",
                          @"Should be a correctly formatted JSON string");
}

- (void)testAsJSONData
{
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};
    NSData *jsonData = [params cou_asJSONData];

    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:params
                                                           options:0
                                                             error:nil];
    
    XCTAssertEqualObjects(jsonData, expectedData, @"Should correctly format as json data");
}

- (void)testAsFormURLEncodedData
{
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};

    NSData *data = [params cou_asFormURLEncodedData];
    
    NSString *dataString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    
    XCTAssertNotNil(dataString, @"Should properly format form URL string as UTF8 string encoded data");

    XCTAssertEqualObjects(dataString,
                          @"key1=value1&key2=value2",
                          @"Should properly format as form URL encoded string");

}

- (void)testAsForURLEncodedString
{
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};
    
    NSString *string = [params cou_asFormURLEncodedString];
    
    XCTAssertEqualObjects(string,
                          @"key1=value1&key2=value2",
                          @"Should properly format as form URL encoded string");
}

@end
