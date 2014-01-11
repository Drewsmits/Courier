//
//  CRSessionController.m
//  Courier
//
//  Created by Andrew Smith on 9/22/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CRSessionController.h"

#import "NSURLResponse+Courier.h"

@interface CRSessionController ()

@property (nonatomic, weak, readwrite) id <CRURLSessionDelegate> controllerDelegate;

@property (nonatomic, readwrite, strong) NSURLSession *session;

@end

@implementation CRSessionController

+ (instancetype)controllerWithConfiguration:(NSURLSessionConfiguration *)configuration
                                   delegate:(id<CRURLSessionDelegate>)delegate
{
    CRSessionController *controller = [[self alloc] init];
    controller.controllerDelegate = delegate;
    controller.session = [NSURLSession sessionWithConfiguration:configuration];
    return controller;
}

- (NSURLSessionTask *)dataTaskForRequest:(NSURLRequest *)request
                       completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 [self handleResponse:response];
                                                 if (completionHandler) completionHandler(data, response, error);
                                             }];
    return task;
}

- (void)handleResponse:(NSURLResponse *)response
{
    if (!response.success) {
        if (response.statusCode == 401) {
            [self.controllerDelegate sessionReceivedUnauthorizedResponse];
        }
    }
}

- (NSURLSessionConfiguration *)configuration
{
    return _session.configuration;
}

@end
