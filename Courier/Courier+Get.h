//
//  Courier+Get.h
//  Courier
//
//  Created by Andrew Smith on 2/2/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "Courier.h"

@interface Courier (Get)

- (void)getPath:(NSString *)path 
  URLParameters:(NSDictionary *)urlParameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure;

- (void)getPath:(NSString *)path 
  URLParameters:(NSDictionary *)urlParameters
usingQueueNamed:(NSString *)queueName
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure;

- (void)getPath:(NSString *)path
     withHeader:(NSDictionary *)header
  URLParameters:(NSDictionary *)urlParameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure;

- (void)getPath:(NSString *)path
     withHeader:(NSDictionary *)header
  URLParameters:(NSDictionary *)urlParameters
usingQueueNamed:(NSString *)queueName
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure;

@end
