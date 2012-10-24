//
//  Courier+Get.m
//  Courier
//
//  Created by Andrew Smith on 2/2/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "Courier.h"
#import "Courier+Get.h"

@implementation Courier (Get)

- (CDOperation *)getPath:(NSString *)path 
           URLParameters:(NSDictionary *)urlParameters
                 success:(CRRequestOperationSuccessBlock)success
                 failure:(CRRequestOperationFailureBlock)failure
{    
    return [self addOperationForPath:path 
                          withMethod:CRRequestMethodGET
                              header:self.defaultHeader
                    andURLParameters:urlParameters
               andHTTPBodyParameters:nil
                        toQueueNamed:nil
                             success:success 
                             failure:failure];
}

- (CDOperation *)getPath:(NSString *)path 
           URLParameters:(NSDictionary *)urlParameters
         usingQueueNamed:(NSString *)queueName
                 success:(CRRequestOperationSuccessBlock)success
                 failure:(CRRequestOperationFailureBlock)failure
{
    return [self addOperationForPath:path 
                          withMethod:CRRequestMethodGET
                              header:self.defaultHeader
                    andURLParameters:urlParameters
               andHTTPBodyParameters:nil
                        toQueueNamed:queueName
                             success:success 
                             failure:failure];
}

- (CDOperation *)getPath:(NSString *)path
              withHeader:(NSDictionary *)header
           URLParameters:(NSDictionary *)urlParameters
                 success:(CRRequestOperationSuccessBlock)success
                 failure:(CRRequestOperationFailureBlock)failure
{    
    return [self addOperationForPath:path 
                          withMethod:CRRequestMethodGET
                              header:header
                    andURLParameters:urlParameters
               andHTTPBodyParameters:nil
                        toQueueNamed:nil
                             success:success 
                             failure:failure];
}

- (CDOperation *)getPath:(NSString *)path
              withHeader:(NSDictionary *)header
           URLParameters:(NSDictionary *)urlParameters
         usingQueueNamed:(NSString *)queueName
                 success:(CRRequestOperationSuccessBlock)success
                 failure:(CRRequestOperationFailureBlock)failure
{
   return [self addOperationForPath:path 
                         withMethod:CRRequestMethodGET
                             header:header
                   andURLParameters:urlParameters
              andHTTPBodyParameters:nil
                       toQueueNamed:queueName
                            success:success 
                            failure:failure];
}

@end
