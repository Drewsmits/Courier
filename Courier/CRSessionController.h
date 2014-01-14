//
//  CRSessionController.h
//  Courier
//
//  Created by Andrew Smith on 9/22/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CRURLSessionControllerDelegate <NSObject>

- (void)sessionReceivedUnauthorizedResponse;

@end

NS_CLASS_AVAILABLE(10_9, 7_0)
@interface CRSessionController : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, weak, readonly) id <CRURLSessionControllerDelegate> controllerDelegate;

/**
 The internal NSURLSession.
 */
@property (nonatomic, strong, readonly) NSURLSession *session;

@property (nonatomic, strong, readonly) NSURLSessionConfiguration *configuration;

+ (instancetype)sessionControllerWithConfiguration:(NSURLSessionConfiguration *)configuration
                                          delegate:(id <CRURLSessionControllerDelegate>)delegate;

- (NSURLSessionTask *)dataTaskForRequest:(NSURLRequest *)request
                       completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

@end
