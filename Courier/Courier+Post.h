//
//  Courier+Post.h
//  Courier
//
//  Created by Andrew Smith on 2/2/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "Courier.h"

@interface Courier (Post)

- (CDOperation *)postPath:(NSString *)path 
   URLParameters:(NSDictionary *)urlParameters
         success:(CRRequestOperationSuccessBlock)success
         failure:(CRRequestOperationFailureBlock)failure;

- (CDOperation *)postPath:(NSString *)path 
            URLParameters:(NSDictionary *)urlParameters
          usingQueueNamed:(NSString *)queueName
                  success:(CRRequestOperationSuccessBlock)success
                  failure:(CRRequestOperationFailureBlock)failure;

- (CDOperation *)postPath:(NSString *)path
            URLParameters:(NSDictionary *)urlParameters
       HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                  success:(CRRequestOperationSuccessBlock)success
                  failure:(CRRequestOperationFailureBlock)failure;

- (CDOperation *)postPath:(NSString *)path
            URLParameters:(NSDictionary *)urlParameters
       HTTPBodyParameters:(NSDictionary *)httpBodyParameters
  addHTTPHeaderParameters:(NSDictionary *)additionalHttpHeaderParameters
          usingQueueNamed:(NSString *)queueName
                  success:(CRRequestOperationSuccessBlock)success
                  failure:(CRRequestOperationFailureBlock)failure;

@end
