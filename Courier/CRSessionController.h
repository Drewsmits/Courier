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

- (instancetype)initWithSession:(NSURLSession *)session;

- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                                 taskHandler:(CRTaskHandler *)handler;

@end
