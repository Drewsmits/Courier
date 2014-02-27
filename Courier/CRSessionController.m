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

#import <UIKit/UIKit.h>

#import "CourierLog.h"

#import "NSURLResponse+Courier.h"

#import "Reachability.h"

@interface CRSessionController () <NSURLSessionDelegate>

@property (nonatomic, weak, readwrite) id <CRURLSessionControllerDelegate> controllerDelegate;

@property (nonatomic, strong, readwrite) NSURLSession *session;

@property (nonatomic, strong) Reachability *reachabilityObject;

@end

@implementation CRSessionController

- (void)dealloc
{
    [_session removeObserver:self forKeyPath:@"delegateQueue.operationCount"];
}

+ (instancetype)sessionControllerWithConfiguration:(NSURLSessionConfiguration *)configuration
                                          delegate:(id <CRURLSessionControllerDelegate>)delegate
{
    CRSessionController *controller = [[self alloc] init];
    controller.controllerDelegate = delegate;
    
    //
    // Internal session
    //
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    controller.session = session;
    
    //
    // Reachability
    //
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    __weak typeof(controller) weakSelf = controller;
    [reachability setUnreachableBlock:^(Reachability * reachability){
        CourierLogWarning(@"Network is unreachable!");
        __strong typeof(controller) strongSelf = weakSelf;
        [strongSelf.controllerDelegate sessionReceivedUnreachableResponse:nil];
    }];
    
    controller.reachabilityObject = reachability;
    
    //
    // Network activity
    //
    // Observe adding/removing operations to the delegate queue to show network
    // activity.
    //
    [session addObserver:controller
              forKeyPath:@"delegateQueue.operationCount"
                 options:NSKeyValueObservingOptionNew context:nil];
    
    return controller;
}

- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                           completionHandler:(void (^)(NSData *data,
                                                       NSURLResponse *response,
                                                       NSError *error))completionHandler
{
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 __strong typeof(self) strongSelf = weakSelf;
                                                 [strongSelf handleResponse:response];
                                                 if (completionHandler) completionHandler(data, response, error);
                                             }];
    return task;
}

- (void)handleResponse:(NSURLResponse *)response
{
    CourierLogInfo(@"URL: %@, status code: %i", response.URL, response.statusCode);
    if (!response.success) {
        if (response.statusCode == 401) {
            [_controllerDelegate sessionReceivedUnauthorizedResponse:response];
        }
    }
}

- (NSURLSessionConfiguration *)configuration
{
    return _session.configuration;
}

#pragma mark - API

- (BOOL)isInternetReachable
{
    return _reachabilityObject.isReachable;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"delegateQueue.operationCount"]
        && [object isEqual:_session]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = (_session.delegateQueue.operationCount > 0);
    }
}

@end
