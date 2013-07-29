//
//  CourierReachabilityTests.m
//  Courier
//
//  Created by Andrew Smith on 7/29/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CourierReachabilityTests.h"
#import "CRRequestOperation.h"
#import "CRRequestQueueController.h"
#import "NSMutableURLRequest+Courier.h"

#define TEST_QUEUE @"com.courierTests.requestQueue"

@interface CourierReachabilityTests ()

@property (nonatomic, strong) CRRequestQueueController *testQueueController;

@end

@implementation CourierReachabilityTests

- (void)setUp
{
  [super setUp];
  
  CRRequestQueueController *queueController = [CRRequestQueueController new];
  CDOperationQueue *queue = [CDOperationQueue queueWithName:TEST_QUEUE];
  [queueController addQueue:queue];
  
  self.testQueueController = queueController;
}

- (void)testUnreachableURL
{
  [self.testQueueController monitorReachability];
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"GET"
                                                                   path:@"http://request.com/to/nowhere"];
  
  __block BOOL shouldBeUnreachable = NO;
  CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request
                                                                   success:nil
                                                                   failure:^(NSMutableURLRequest *request, CRResponse *response, NSError *error, BOOL unreachable) {
                                                                     shouldBeUnreachable = unreachable;
                                                                   }];
  
  __block BOOL hasCalledBack = NO;
  operation.completionBlock = ^{
    hasCalledBack = YES;
  };
  
  [self.testQueueController addOperation:operation
                            toQueueNamed:TEST_QUEUE];
    
  NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
  while (hasCalledBack == NO) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:loopUntil];
  }
  
  STAssertTrue(shouldBeUnreachable, @"Unreachable should be YES");
}

@end
