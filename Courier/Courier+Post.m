//
//  Courier+Post.m
//  Courier
//
//  Created by Andrew Smith on 2/2/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "Courier.h"
#import "Courier+Post.h"

@implementation Courier (Post)

- (CDOperation *)postPath:(NSString *)path 
            URLParameters:(NSDictionary *)urlParameters
                  success:(CRRequestOperationSuccessBlock)success
                  failure:(CRRequestOperationFailureBlock)failure
{    
    return [self addOperationForPath:path
                          withMethod:CRRequestMethodPOST
                              header:[self defaultHeader]
                    andURLParameters:urlParameters
               andHTTPBodyParameters:nil
                        toQueueNamed:nil
                             success:success 
                             failure:failure];
}

- (CDOperation *)postPath:(NSString *)path 
            URLParameters:(NSDictionary *)urlParameters
          usingQueueNamed:(NSString *)queueName
                  success:(CRRequestOperationSuccessBlock)success
                  failure:(CRRequestOperationFailureBlock)failure
{
    return [self addOperationForPath:path
                          withMethod:CRRequestMethodPOST
                              header:[self defaultHeader]
                    andURLParameters:urlParameters
               andHTTPBodyParameters:nil
                        toQueueNamed:queueName
                             success:success 
                             failure:failure];
    
}

- (CDOperation *)postPath:(NSString *)path
            URLParameters:(NSDictionary *)urlParameters
       HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                  success:(CRRequestOperationSuccessBlock)success
                  failure:(CRRequestOperationFailureBlock)failure
{    
    return [self addOperationForPath:path
                          withMethod:CRRequestMethodPOST
                              header:[self defaultHeader]
                    andURLParameters:urlParameters
               andHTTPBodyParameters:httpBodyParameters
                        toQueueNamed:nil
                             success:success 
                             failure:failure];
}

- (CDOperation *)postPath:(NSString *)path 
            URLParameters:(NSDictionary *)urlParameters
       HTTPBodyParameters:(NSDictionary *)httpBodyParameters
  addHTTPHeaderParameters:(NSDictionary *)additionalHttpHeaderParameters
          usingQueueNamed:(NSString *)queueName
                  success:(CRRequestOperationSuccessBlock)success
                  failure:(CRRequestOperationFailureBlock)failure
{
    NSMutableDictionary *header = [self defaultHeader];
    
    if (additionalHttpHeaderParameters) {
        [header addEntriesFromDictionary:additionalHttpHeaderParameters];
    }
    
    return [self addOperationForPath:path
                          withMethod:CRRequestMethodPOST
                              header:header
                    andURLParameters:urlParameters
               andHTTPBodyParameters:httpBodyParameters
                        toQueueNamed:queueName
                             success:success 
                             failure:failure];
}

@end
