//
//  CRTaskHandler.m
//  Courier
//
//  Created by Andrew Smith on 9/29/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CRTaskHandler.h"

@interface CRTaskHandler ()

@property (nonatomic, copy, readwrite) CRURLTaskCompletionHandler completionHandler;

@property (nonatomic, copy, readwrite) CRTaskDidRecieveDataHandler didRecieveDataHandler;

@end

@implementation CRTaskHandler

- (void)setTaskDidCompleteBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, NSError *error))completion
{
    _completionHandler = completion;
}

- (void)setTaskDidRecieveDataHandler:(void (^)(NSURLSession *session, NSURLSessionTask *task, NSData *data))handler
{
    _didRecieveDataHandler = handler;
}

@end
