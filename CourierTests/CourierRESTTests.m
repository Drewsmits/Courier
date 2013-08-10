//
//  CourierRESTTests.m
//  Courier
//
//  Created by Andrew Smith on 8/9/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CourierRESTTests.h"
#import "NSMutableURLRequest+Courier.h"
#import "CRRequestController.h"
#import "CRRequestOperation.h"
#import "CRTestMacros.h"
#import "CRResponse.h"

@interface CourierRESTTests ()

@property (nonatomic, strong) CDQueueController *testQueueController;

@end

@implementation CourierRESTTests

- (void)testGetRequest
{
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"GET"
                                                                   path:@"http://localhost:9000/getTest"];
  
  CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request];
  __block BOOL hasCalledBack = NO;
  operation.completionBlock = ^{
    hasCalledBack = YES;
  };
  
  [self.testQueueController addOperation:operation
                            toQueueNamed:TEST_QUEUE];
  
  WAIT_ON_BOOL(hasCalledBack)
  
  STAssertEquals(operation.response.statusCode, 200, @"Response should be 200 OK!");
}

- (void)testPostRequest
{
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"POST"
                                                                   path:@"http://localhost:9000/postTest"];
  
  CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request];
  __block BOOL hasCalledBack = NO;
  operation.completionBlock = ^{
    hasCalledBack = YES;
  };
  
  [self.testQueueController addOperation:operation
                            toQueueNamed:TEST_QUEUE];
  
  WAIT_ON_BOOL(hasCalledBack)
  
  STAssertEquals(operation.response.statusCode, 200, @"Response should be 200 OK!");
}

- (void)testPutRequest
{
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"PUT"
                                                                   path:@"http://localhost:9000/putTest"];
  
  CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request];
  __block BOOL hasCalledBack = NO;
  operation.completionBlock = ^{
    hasCalledBack = YES;
  };
  
  [self.testQueueController addOperation:operation
                            toQueueNamed:TEST_QUEUE];
  
  WAIT_ON_BOOL(hasCalledBack)
  
  STAssertEquals(operation.response.statusCode, 200, @"Response should be 200 OK!");
}

- (void)testDeleteRequest
{
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"DELETE"
                                                                   path:@"http://localhost:9000/deleteTest"];
  
  CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request];
  __block BOOL hasCalledBack = NO;
  operation.completionBlock = ^{
    hasCalledBack = YES;
  };
  
  [self.testQueueController addOperation:operation
                            toQueueNamed:TEST_QUEUE];
  
  WAIT_ON_BOOL(hasCalledBack)
  
  STAssertEquals(operation.response.statusCode, 200, @"Response should be 200 OK!");
}

@end
