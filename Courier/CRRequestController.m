//
//  CRRequestController.m
//  Courier
//
//  Created by Andrew Smith on 6/13/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CRRequestController.h"

#import "CRRequestOperation.h"
#import "Reachability.h"

@implementation CRRequestController

- (id)init
{
  self = [super init];
  if (self) {
    _defaultHeader = [NSMutableDictionary new];
  }
  return self;
}

+ (CRRequestController *)controllerWithDefaultHeader:(NSDictionary *)header
{
  CRRequestController *controller = [self new];
  controller.defaultHeader = [header mutableCopy];
  return controller;
}

#pragma mark - Reachability

- (BOOL)isPathReachable:(NSString *)path
       unreachableBlock:(CRRequestOperationFailureBlock)unreachableBlock
{
    if (!path) return NO;
    
    // Build reachability with address
    struct sockaddr_in address;
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons(9000);
    address.sin_addr.s_addr = inet_addr((const char*)[path UTF8String]);
    Reachability *reach = [Reachability reachabilityWithAddress:&address];
    
    if ([reach currentReachabilityStatus] == NotReachable) {
      WLog(@"\nReachability failed! \n%@ is not reachable", path);
      
      if (unreachableBlock) {
        // Fail with unreachable flag set to yes
        unreachableBlock(nil, nil, nil, YES);
      }
      
      return NO;
    } else {
      return YES;
    }
}


@end
