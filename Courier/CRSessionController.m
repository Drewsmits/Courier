//
//  CRSessionController.m
//  Courier
//
//  Created by Andrew Smith on 9/22/13.
//  Copyright (c) 2013 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "CRSessionController.h"

#import "NSURLResponse+Courier.h"

@interface CRSessionController ()

@property (nonatomic, weak, readwrite) id <CRURLSessionControllerDelegate> controllerDelegate;

@property (nonatomic, readwrite, strong) NSURLSession *session;

@end

@implementation CRSessionController

+ (instancetype)sessionControllerWithConfiguration:(NSURLSessionConfiguration *)configuration
                                   delegate:(id <CRURLSessionControllerDelegate>)delegate
{
    CRSessionController *controller = [[self alloc] init];
    controller.controllerDelegate = delegate;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    controller.session = session;
    
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
