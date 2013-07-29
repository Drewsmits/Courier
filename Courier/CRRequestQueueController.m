//
//  CRRequestOperationController.m
//  Courier
//
//  Created by Andrew Smith on 7/26/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CRRequestQueueController.h"
#import "Reachability.h"

@interface CRRequestQueueController ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *defaultHeader;
@property (nonatomic, strong) Reachability *reachabilityObject;

@end

@implementation CRRequestQueueController

- (void)dealloc
{
  [_reachabilityObject stopNotifier];
}

- (id)init
{
  self = [super init];
  if (self) {
    _defaultHeader = [NSMutableDictionary new];
  }
  return self;
}

#pragma mark - Reachability

- (void)startReachabilityNotifier
{
  [self.reachabilityObject startNotifier];
}

- (void)stopReachabilityNotifier
{
  [self.reachabilityObject stopNotifier];
}

- (Reachability *)reachabilityObject
{
  if (_reachabilityObject) return _reachabilityObject;
  
  // Monitor reachability for all internet connections
  _reachabilityObject = [Reachability reachabilityForInternetConnection];
  
  __weak CRRequestQueueController *weakSelf = self;
  
  // Reachable block
  _reachabilityObject.reachableBlock = ^(Reachability *reach) {
    NSLog(@"internet is back!");
  };
  
  // Unreachable block
  _reachabilityObject.unreachableBlock = ^(Reachability *reach) {
    NSLog(@"internet is gone!");
    // Flush out any operations from the queue...is this really what we want to do?
    [weakSelf cancelAllOperations];
  };
  
  return _reachabilityObject;
}

@end
