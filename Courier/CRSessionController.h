//
//  CRSessionController.h
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

#import <Foundation/Foundation.h>

@protocol CRURLSessionControllerDelegate <NSObject>

- (void)sessionReceivedUnauthorizedResponse:(NSURLResponse *)response;

- (void)sessionReceivedUnreachableResponse:(NSURLResponse *)response;

@end

NS_CLASS_AVAILABLE(10_9, 7_0)
@interface CRSessionController : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, weak, readonly) id <CRURLSessionControllerDelegate> controllerDelegate;

/**
 The internal NSURLSession.
 */
@property (nonatomic, strong, readonly) NSURLSession *session;

/**
 The internal NSURLSessionConfiguration from the internal NSURLSession.
 */
@property (nonatomic, strong, readonly) NSURLSessionConfiguration *configuration;

+ (instancetype)sessionControllerWithConfiguration:(NSURLSessionConfiguration *)configuration
                                          delegate:(id <CRURLSessionControllerDelegate>)delegate;

- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                           completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

- (BOOL)isInternetReachable;

@end
