//
//  Courier.h
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Conductor.h"

#import "CRRequest.h"
#import "CRRequestOperation.h"

@interface Courier : Conductor {
@private
    NSMutableDictionary *defaultHeader;
    NSString *baseAPIPath;
}

/**
 Default headers used for every request
 */
@property (nonatomic, readonly) NSMutableDictionary *defaultHeader;

/**
 Route on which all API requests are relative to
 */
@property (nonatomic, retain) NSString *baseAPIPath;

/**
 Add the username and password to the Basic Auth header in the default header.
 Username and password are encrypted.
 */
- (void)setBasicAuthUsername:(NSString *)username 
                 andPassword:(NSString *)password;

- (void)getPath:(NSString *)path 
     parameters:(NSDictionary *)parameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure;

- (void)putPath:(NSString *)path 
     parameters:(NSDictionary *)parameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure;

- (void)postPath:(NSString *)path 
      parameters:(NSDictionary *)parameters
         success:(CRRequestOperationSuccessBlock)success
         failure:(CRRequestOperationFailureBlock)failure;

- (void)postPath:(NSString *)path 
      parameters:(NSDictionary *)parameters
        httpBody:(NSData *)bodyData
         success:(CRRequestOperationSuccessBlock)success
         failure:(CRRequestOperationFailureBlock)failure;

- (void)deletePath:(NSString *)path 
        parameters:(NSDictionary *)parameters
           success:(CRRequestOperationSuccessBlock)success
           failure:(CRRequestOperationFailureBlock)failure;

@end
