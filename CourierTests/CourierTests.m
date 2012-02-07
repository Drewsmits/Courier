//
//  CourierTests.m
//  CourierTests
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
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
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
//

#import "CourierTests.h"

#import "Courier.h"
#import "Courier+Get.h"
#import "Courier+Post.h"

#import "CRRequest.h"
#import "CRRequestOperation.h"

@implementation CourierTests

- (void)setUp {
    [super setUp];

}

- (void)tearDown{
    [super tearDown];
}

#pragma mark - CRRequest

- (void)testCreateRequest {

    NSString *path = @"path/to/some/resource";
    
    NSDictionary *URLParams = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"one", @"two", @"three", nil]
                                                          forKeys:[NSArray arrayWithObjects:@"A"  , @"B"  , @"C"    , nil]];

    NSDictionary *HTTPBodyParams = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"four", @"five", @"six", nil]
                                                               forKeys:[NSArray arrayWithObjects:@"D"  , @"E"  , @"F"    , nil]];
        
    CRRequest *request = [CRRequest requestWithMethod:CRRequestMethodGET
                                              forPath:path
                                    withURLParameters:URLParams
                                andHTTPBodyParameters:HTTPBodyParams
                                            andHeader:nil
                                  shouldHandleCookies:NO];

    STAssertNotNil(request, @"Should create request");
    STAssertEquals(request.method, CRRequestMethodGET, @"Request should have correct method");
    STAssertEqualObjects(request.path, path, @"Request should have correct path");
    STAssertEqualObjects(request.URLParameters, URLParams, @"Request should have correct params");
    STAssertEqualObjects(request.HTTPBodyParameters, HTTPBodyParams, @"Request should have correct HTTP body");
}

- (void)testRequestURL {
    NSString *path = @"path/to/some/resource";
    
    NSDictionary *URLParams = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"one", @"two", @"three", nil]
                                                          forKeys:[NSArray arrayWithObjects:@"A"  , @"B"  , @"C"    , nil]];

    CRRequest *request = [CRRequest requestWithMethod:CRRequestMethodGET
                                              forPath:path
                                    withURLParameters:URLParams
                                andHTTPBodyParameters:nil
                                            andHeader:nil
                                  shouldHandleCookies:NO];
    
    NSString *expectedPath = [NSString stringWithFormat:@"%@?A=one&B=two&C=three", path];
    NSURL *expectedURL = [NSURL URLWithString:expectedPath];
    
    STAssertEqualObjects(request.requestURL, expectedURL, @"Request should have correct request URL");
}

- (void)testRequsetHTTPBodyParameters {
    NSString *path = @"path/to/some/resource";
        
    NSDictionary *HTTPBodyParams = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"four", @"five", @"six", nil]
                                                               forKeys:[NSArray arrayWithObjects:@"D"  , @"E"  , @"F"    , nil]];
    
    CRRequest *request = [CRRequest requestWithMethod:CRRequestMethodGET
                                              forPath:path
                                    withURLParameters:nil
                                andHTTPBodyParameters:HTTPBodyParams
                                            andHeader:nil
                                  shouldHandleCookies:NO];
    
    NSString *expectedString = [NSString stringWithString:@"D=four&E=five&F=six"];
        
    NSString *string = [[NSString alloc] initWithData:[request HTTPBodyData]
                                             encoding:NSUTF8StringEncoding];
    
    STAssertEqualObjects(expectedString, string, @"Should have correct HTTP body data");
}

- (void)testRequestHeader {
    
    NSDictionary *header = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"four", @"five", @"six", nil]
                                                       forKeys:[NSArray arrayWithObjects:@"D"  , @"E"  , @"F"    , nil]];
    
    CRRequest *request = [CRRequest requestWithMethod:CRRequestMethodGET
                                              forPath:nil
                                    withURLParameters:nil
                                andHTTPBodyParameters:nil
                                            andHeader:header
                                  shouldHandleCookies:NO];
    
    STAssertEqualObjects(header, [request header], @"Request should have correct header");
}

#pragma mark - CRRequestOperation

- (void)testGetRequest {
        
    NSString *path = @"http://localhost:4567/gettest";

    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
                
        if ([response statusCode] == 200) {            
            success = YES;
        }
        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error, BOOL unreachable){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
        
    [[Courier sharedInstance] getPath:path
                        URLParameters:nil
                              success:successBlock 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }

    STAssertTrue(success, @"Response should be 200");
}

- (void)testGetRequestWithURLThatDoesntExist {
    
    NSString *path = @"http://localhost:4567/a-route-that-doesnt-exist";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL expectedResponse = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error, BOOL unreachable){        
        hasCalledBack = YES;
        
        if ([response statusCode] == 404) {
            expectedResponse = YES;
        }
        
    }; 
    
    [[Courier sharedInstance] getPath:path
                        URLParameters:nil
                              success:successBlock 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(expectedResponse, @"Response should be 404");
}

- (void)testPutRequest {
    
    NSString *path = @"http://localhost:4567/puttest";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
        
        if ([response statusCode] == 200) {            
            success = YES;
        }
        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error, BOOL unreachable){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
    
    [[Courier sharedInstance] putPath:path
                        URLParameters:nil
                              success:successBlock 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Response should be 200");
}

- (void)testPostRequest {
    
    NSString *path = @"http://localhost:4567/posttest";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
        
        if ([response statusCode] == 200) {            
            success = YES;
        }
        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error, BOOL unreachable){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
    
    [[Courier sharedInstance] postPath:path
                         URLParameters:nil
                               success:successBlock 
                               failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Response should be 200");
}

- (void)testDeleteRequest {
    
    NSString *path = @"http://localhost:4567/deletetest";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
        success = YES;        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error, BOOL unreachable){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
    
    [[Courier sharedInstance] deletePath:path
                              URLParameters:nil
                                 success:successBlock 
                                 failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Response should be 200");
}

- (void)testGetRequestWithParameters {
    
    NSString *path = @"http://localhost:4567/parameter";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
        success = YES;        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error, BOOL unreachable){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"myValue" forKey:@"myKey"];
    
    [[Courier sharedInstance] getPath:path
                        URLParameters:params
                              success:successBlock 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Should properly send parameters");
}

- (void)testGetRequestWithWrongParameters {
    
    NSString *path = @"http://localhost:4567/parameter";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error, BOOL unreachable){        
        hasCalledBack = YES;
        
        if ([response statusCode] == 500) {            
            success = YES;
        }
    }; 
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"blarg" forKey:@"gigigts"];
    
    [[Courier sharedInstance] getPath:path
                        URLParameters:params
                              success:nil 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Response should be 500");
}

- (void)testPostPathWithHTTPBody {
    
    NSString *path = @"http://localhost:4567/posttestwithdata";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
        
        if ([response statusCode] == 200) {            
            success = YES;
        }
        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error, BOOL unreachable){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"object1", @"key1", @"object2", @"key2", nil];
    
    [[Courier sharedInstance] postPath:path
                         URLParameters:nil
                    HTTPBodyParameters:dict
                               success:successBlock 
                               failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Response should be 200");
}

- (void)testReachabilitySuccessTest {
    
    __block BOOL unreachable = NO;

    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error, BOOL unreachable){        
        unreachable = YES;
    }; 
    
    [[Courier sharedInstance] isPathReachable:@"www.google.com"
                             unreachableBlock:failBlock];
    

    STAssertFalse(unreachable, @"Google should be reachable");
}

- (void)testReachabilityFailTest {
    
    __block BOOL unreachable = NO;
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error, BOOL unreachable){        
        unreachable = YES;
    }; 
    
    [[Courier sharedInstance] isPathReachable:@"whatever"
                             unreachableBlock:failBlock];
    
    STAssertFalse(unreachable, @"\"Whatever\" should be unreachable.");
}
@end
