//
//  CRRequest.h
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CRRequestMethodGET,
    CRRequestMethodPUT,
    CRRequestMethodPOST,
    CRRequestMethodDELETE,
}CRRequestMethod;

@interface CRRequest : NSObject {
@private
    CRRequestMethod method;
    NSMutableDictionary *parameters;
    NSMutableDictionary *defaultHeader;
    NSString *path;
}

@property (nonatomic, assign) CRRequestMethod method;
@property (nonatomic, readonly) NSString *requestMethodString;

@property (readonly, nonatomic, copy) NSString *path;
@property (readonly, nonatomic, retain) NSDictionary *parameters;

@property (nonatomic, readonly) NSDictionary *header;
@property (nonatomic, retain) NSMutableDictionary *defaultHeader;

@property (nonatomic, readonly) NSString *queryString;
@property (nonatomic, readonly) NSURL *requestURL;

+ (CRRequest *)requestWithMethod:(CRRequestMethod)method
                         forPath:(NSString *)path
                  withParameters:(NSDictionary *)parameters
                       andHeader:(NSDictionary *)header;

- (NSMutableURLRequest *)URLRequest;

@end
