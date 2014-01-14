//
//  NSDictionaryCourierTests.m
//  Courier
//
//  Created by Andrew Smith on 1/13/14.
//  Copyright (c) 2014 Andrew B. Smith. All rights reserved.
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

    NSString *jsonParams = [params asJSONString];
    
    XCTAssertEqualObjects(jsonParams,
                          @"{\"key2\":\"value2\",\"key1\":\"value1\"}",
                          @"Should be a correctly formatted JSON string");
}

- (void)testAsJSONData
{
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};
    NSData *jsonData = [params asJSONData];

    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:params
                                                           options:0
                                                             error:nil];
    
    XCTAssertEqualObjects(jsonData, expectedData, @"Should correctly format as json data");
}

- (void)testAsFormURLEncodedData
{
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};

    NSData *data = [params asFormURLEncodedData];
    
    NSString *dataString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    
    XCTAssertNotNil(dataString, @"Should properly format form URL string as UTF8 string encoded data");

    XCTAssertEqualObjects(dataString,
                          @"key2=value2&key1=value1",
                          @"Should properly format as form URL encoded string");

}

- (void)testAsForURLEncodedString
{
    NSDictionary *params = @{@"key1" : @"value1", @"key2" : @"value2"};
    
    NSString *string = [params asFormURLEncodedString];
    
    XCTAssertEqualObjects(string,
                          @"key2=value2&key1=value1",
                          @"Should properly format as form URL encoded string");
}

@end
