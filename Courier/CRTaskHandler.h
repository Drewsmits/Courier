//
//  CRTaskHandler.h
//  Courier
//
//  Created by Andrew Smith on 9/29/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CRURLTaskCompletionHandler)(NSURLSession *session, NSURLSessionTask *task, NSError *error);
typedef void (^CRTaskDidRecieveDataHandler)(NSURLSession *session, NSURLSessionDataTask *task, NSData *data);

@interface CRTaskHandler : NSObject <NSURLSessionDelegate>

@property (nonatomic, strong) NSString *taskId;

@property (nonatomic, copy, readonly) CRURLTaskCompletionHandler completionHandler;

@property (nonatomic, copy, readonly) CRTaskDidRecieveDataHandler didRecieveDataHandler;

- (void)setTaskDidCompleteBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, NSError *error))completion;

- (void)setTaskDidRecieveDataHandler:(void (^)(NSURLSession *session, NSURLSessionTask *task, NSData *data))handler;

@end
