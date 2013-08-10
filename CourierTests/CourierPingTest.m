//
//  CourierPingTest.m
//  Courier
//
//  Created by Andrew Smith on 7/26/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CourierPingTest.h"
#import "NSMutableURLRequest+Courier.h"
#import "CRRequestController.h" 
#import "CRRequestOperation.h"
#import "CRResponse.h"
#import "CRTestMacros.h"

@interface CourierPingTest ()

@property (nonatomic, strong) CDQueueController *testQueueController;

@end

@implementation CourierPingTest

- (void)setUp
{
  [super setUp];

  CDQueueController *queueController = [CDQueueController new];
  CDOperationQueue *queue = [CDOperationQueue queueWithName:TEST_QUEUE];
  [queueController addQueue:queue];
  
  self.testQueueController = queueController;
}

- (void)testPing200
{
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"GET"
                                                                   path:@"http://localhost:9000/ping/200"];
  
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

- (void)testPing404
{
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"GET"
                                                                   path:@"http://localhost:9000/ping/404"];
  
  __block BOOL failedBlockRan = NO;
  CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request
                                                                   success:nil
                                                                   failure:^(NSMutableURLRequest *request, CRResponse *response, NSError *error, BOOL unreachable) {
    failedBlockRan = YES;
  }];
  
  __block BOOL hasCalledBack = NO;
  operation.completionBlock = ^{
    hasCalledBack = YES;
  };
  
  [self.testQueueController addOperation:operation
                            toQueueNamed:TEST_QUEUE];
  
  WAIT_ON_BOOL(hasCalledBack)
  
  STAssertEquals(operation.response.statusCode, 404, @"Response should be 404!");
  STAssertFalse(operation.response.success, @"Response should report failure");
  STAssertTrue(failedBlockRan, @"Failed operation should run fail block");
}

@end
