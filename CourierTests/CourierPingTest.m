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
#import "CDQueueController.h"

#define TEST_QUEUE @"com.courier.requestQueue"

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
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"POST"
                                                                   path:@"http://localhost:9000/ping/200"
                                                               encoding:CR_URLRequestEncodingUnknown
                                                          URLParameters:nil
                                                     HTTPBodyParameters:nil
                                                                 header:nil
                                                    shouldHandleCookies:NO];
  
  __block BOOL hasCalledBack = NO;
  __block BOOL success = NO;
  CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request
                                                                   success:^(NSMutableURLRequest *request, CRResponse *response) {
                                                                     hasCalledBack = YES;
                                                                     success = (response.statusCode == 200);
                                                                   } failure:^(NSMutableURLRequest *request, CRResponse *response, NSError *error, BOOL unreachable) {
                                                                     hasCalledBack = YES;
                                                                   }];
  

  [self.testQueueController addOperation:operation
                            toQueueNamed:TEST_QUEUE];
  
  NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
  while (hasCalledBack == NO) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:loopUntil];
  }
  
  STAssertTrue(success, @"Response should be 200,OK!");
}

@end
