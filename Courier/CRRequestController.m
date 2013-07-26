//
//  CRRequestController.m
//  Courier
//
//  Created by Andrew Smith on 6/13/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CRRequestController.h"

#import "CRRequest.h"
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

- (CRRequestOperation *)operationForRequest:(CRRequest *)request
                                    success:(CRRequestOperationSuccessBlock)success
                                    failure:(CRRequestOperationFailureBlock)failure
{
    //
    // Test reachability
    //
    if (![self isPathReachable:request.path unreachableBlock:failure]) {
        return nil;
    }
  
    //
    // Add default header values. The keys for the request header will stomp the
    // default header values. This allways allows the user to override defaults if
    // they want to when building the request
    //
    NSMutableDictionary *tempHeader = [self.defaultHeader mutableCopy];
    [tempHeader addEntriesFromDictionary:request.header];
    request.header = tempHeader;

    //
    // Build operation
    //
    CRRequestOperation *operation = [CRRequestOperation operationWithRequest:request
                                                                     success:success
                                                                     failure:failure];
  
    return operation;
}


- (CRRequestOperation *)operationForURLRequest:(NSMutableURLRequest *)request
                                       success:(CRRequestOperationSuccessBlock)success
                                       failure:(CRRequestOperationFailureBlock)failure
{
  
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
