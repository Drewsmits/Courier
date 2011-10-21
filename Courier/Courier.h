//
//  Courier.h
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CRRequest.h"
#import "CRRequestOperation.h"

@interface Courier : NSObject {
@private
    NSOperationQueue *operationQueue;
}

+ (id)sharedInstance;

- (void)getPath:(NSString *)path 
     parameters:(NSDictionary *)parameters
        success:(CRRequestOperationSuccessBlock)success
        failure:(CRRequestOperationFailureBlock)failure;

- (NSDictionary *)defaultHeader;

@end
