//
//  Courier+Post.m
//  Courier
//
//  Created by Andrew Smith on 2/2/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "Courier+Post.h"

@implementation Courier (Post)

- (void)postPath:(NSString *)path 
   URLParameters:(NSDictionary *)urlParameters
         success:(CRRequestOperationSuccessBlock)success
         failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path
                   withMethod:CRRequestMethodPOST
                       header:[self defaultHeader]
             andURLParameters:urlParameters
        andHTTPBodyParameters:nil
                 toQueueNamed:nil
                      success:success 
                      failure:failure];
}

- (void)postPath:(NSString *)path 
   URLParameters:(NSDictionary *)urlParameters
 usingQueueNamed:(NSString *)queueName
         success:(CRRequestOperationSuccessBlock)success
         failure:(CRRequestOperationFailureBlock)failure {

    [self addOperationForPath:path
                   withMethod:CRRequestMethodPOST
                       header:[self defaultHeader]
             andURLParameters:urlParameters
        andHTTPBodyParameters:nil
                 toQueueNamed:queueName
                      success:success 
                      failure:failure];
    
}

- (void)postPath:(NSString *)path URLParameters:(NSDictionary *)urlParameters
                             HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                                        success:(CRRequestOperationSuccessBlock)success
                                        failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path
                   withMethod:CRRequestMethodPOST
                       header:[self defaultHeader]
             andURLParameters:urlParameters
        andHTTPBodyParameters:httpBodyParameters
                 toQueueNamed:nil
                      success:success 
                      failure:failure];
}

- (void)postPath:(NSString *)path URLParameters:(NSDictionary *)urlParameters
                             HTTPBodyParameters:(NSDictionary *)httpBodyParameters
                                usingQueueNamed:(NSString *)queueName
                                        success:(CRRequestOperationSuccessBlock)success
                                        failure:(CRRequestOperationFailureBlock)failure {
    
    [self addOperationForPath:path
                   withMethod:CRRequestMethodPOST
                       header:[self defaultHeader]
             andURLParameters:urlParameters
        andHTTPBodyParameters:httpBodyParameters
                 toQueueNamed:queueName
                      success:success 
                      failure:failure];
}

@end
