//
//  CRSessionController.h
//  Courier
//
//  Created by Andrew Smith on 9/22/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CRTaskHandler;

NS_CLASS_AVAILABLE(10_9, 7_0)
@interface CRSessionController : NSObject <NSURLSessionDataDelegate>

/**
 The internal NSURLSession.
 */
@property (nonatomic, readonly, strong) NSURLSession *session;

/**
 Task handlers
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *taskHandlers;

/**
 BOOL for checking the suspended state of the internal NSURLSession
 @return bool Returns YES if the internal NSURLSession is suspended, NO otherwise.
 */
@property (getter = isSesssionSuspended) BOOL sessionSuspended;

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
                                    delegate:(id <NSURLSessionDelegate>)sessionDelegate
                               delegateQueue:(NSOperationQueue *)queue;

- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                                 taskHandler:(CRTaskHandler *)handler;

@end
