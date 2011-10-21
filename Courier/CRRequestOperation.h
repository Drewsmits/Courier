//
//  CRHTTPRequestOperation.h
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CRRequest.h"
#import "CRResponse.h"

typedef void (^CRRequestOperationSuccessBlock)(CRRequest *request, CRResponse *response);
typedef void (^CRRequestOperationFailureBlock)(CRRequest *request, CRResponse *response, NSError *error);

@interface CRRequestOperation : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
@private    
    
    NSURLConnection *connection;
    CRRequest *request;
    CRResponse *response;
    //UIBackgroundTaskIdentifier backgroundTask;
}

@property (readonly, nonatomic, retain) NSURLConnection *connection;
@property (readonly, nonatomic, retain) CRRequest *request;
@property (readonly, nonatomic, retain) CRResponse *response;

+ (id)operationWithRequest:(CRRequest *)aRequest 
                   success:(CRRequestOperationSuccessBlock)successBlock
                   failure:(CRRequestOperationFailureBlock)failureBlock;

@end
