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

@protocol CRURLSessionControllerDelegate;

NS_CLASS_AVAILABLE(10_9, 7_0)
@interface CRSessionController : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, weak, readonly) id <CRURLSessionControllerDelegate> controllerDelegate;

/**
 The internal NSURLSession.
 */
@property (nonatomic, readonly) NSURLSession *session;

/**
 A copy of the internal NSURLSessionConfiguration from the internal NSURLSession.
 */
@property (nonatomic, readonly) NSURLSessionConfiguration *configuration;

/**
 Create a session controller with a delegate for 401 and unreachable callbacks.
 */
+ (instancetype)sessionControllerWithConfiguration:(NSURLSessionConfiguration *)configuration
                                          delegate:(id <CRURLSessionControllerDelegate>)delegate;

/**
 Create an NSURLSessionDataTask for the given request.
*/
- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                           completionHandler:(void (^)(NSData *data,
                                                       NSURLResponse *response,
                                                       BOOL cachedResponse,
                                                       NSError *error))completionHandler;
/**
 Create an NSURLSessionDataTask for the given request and add it to the specified
 non-nil task group. If task group is nil, task will be added to generic group.
 */
- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                                   taskGroup:(NSString *)group
                           completionHandler:(void (^)(NSData *data,
                                                       NSURLResponse *response,
                                                       BOOL cachedResponse,
                                                       NSError *error))completionHandler;

/**
 Returns YES if any internet connection is reachable.
 */
- (BOOL)isInternetReachable;

@end

@protocol CRURLSessionControllerDelegate <NSObject>

/**
 *  Delegates implement this method to handle 401 responses.
 *
 *  @param response The response from an HTTP request
 */
- (void)sessionReceivedUnauthorizedResponse:(NSURLResponse *)response;

/**
 *  Delegates implement this method to handle an unreachable response. This occurs
 *  when the reachability status changes or when a response returns with an 
 *  unreachable status.
 *
 *  @param response The response from an HTTP request
 */
- (void)sessionReceivedUnreachableResponse:(NSURLResponse *)response;

@optional

/**
 *  Delegates implement this method to have an additional hook into handling HTTP
 *  request responses.
 *
 *  @param controller The controller responsible for the request
 *  @param response   The response from an HTTP request
 */
- (void)sessionController:(CRSessionController *)controller
       didRecieveResponse:(NSURLResponse *)response;

@end

@interface CRSessionController (TaskManagement)

/**
 Calls -suspend on all tasks in a given group.
 */
- (void)suspendTasksInGroup:(NSString *)group;

/**
 Calls -resume on all tasks in a given group.
 */
- (void)resumeTasksInGroup:(NSString *)group;

/**
 Calls -cancel on all tasks in a given group.
 */
- (void)cancelTasksInGroup:(NSString *)group;

/**
 Calls -suspend on all tasks tracked by this controller
 */
- (void)suspendAllTasks;

/**
 Calls -resume on all tasks tracked by this controller
 */
- (void)resumeAllTasks;

/**
 Calls -cancel on all tasks tracked by this controller
 */
- (void)cancelAllTasks;

@end

@interface CRSessionController (Debug)

- (void)logRequests;

@end
