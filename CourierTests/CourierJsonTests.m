//
//  CourierJsonTests.m
//  Courier
//
//  Created by Andrew Smith on 7/29/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CourierJsonTests.h"
#import "NSMutableURLRequest+Courier.h"
#import "CRRequestController.h"
#import "CRRequestOperation.h"
#import "CRResponse.h"
#import "CRTestMacros.h"

@interface CourierJsonTests ()

@property (nonatomic, strong) CDQueueController *testQueueController;

@end

@implementation CourierJsonTests

- (void)setUp
{
  [super setUp];
  
  CDQueueController *queueController = [CDQueueController new];
  CDOperationQueue *queue = [CDOperationQueue queueWithName:TEST_QUEUE];
  [queueController addQueue:queue];
  
  self.testQueueController = queueController;
}

- (void)testPostJson
{  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"POST"
                                                                   path:@"http://localhost:9000/testJsonPost"
                                                               encoding:CR_URLJSONParameterEncoding
                                                          URLParameters:nil
                                                     HTTPBodyParameters:@{@"name" : @"Drewsmits"}
                                                                 header:nil];
  
  CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request];
  __block BOOL hasCalledBack = NO;
  operation.completionBlock = ^{
    hasCalledBack = YES;
  };
  
  [self.testQueueController addOperation:operation
                            toQueueNamed:TEST_QUEUE];
  
  WAIT_ON_BOOL(hasCalledBack);
  
  STAssertTrue(operation.response.success, @"Test post JSON should be successful");
}

@end
