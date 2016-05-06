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

#if TARGET_OS_IOS
#import <Reachability/Reachability.h>
#endif

/**
 The CRSessionController wraps around an NSURLSession. Use this class to create and managed tasks. For
 instance, you can group tasks by name and bulk cancel said group.
 */
NS_CLASS_AVAILABLE(10_9, 7_0)
@interface CRSessionController : NSObject

/**
 The internal NSURLSession.
 */
@property (nonatomic, readonly, strong) NSURLSession *session;

/**
 The NSOperationQueue on which the NSURLSessions delegate callbacks are run.
 */
@property (nonatomic, readonly, strong) NSOperationQueue *sessionDelegateOperationQueue;

/**
 A copy of the internal NSURLSessionConfiguration from the internal NSURLSession.
 */
@property (nonatomic, readonly) NSURLSessionConfiguration *configuration;

/**
 Create a session controller with the given NSURLSessionConfiguration. Note that once a configuration
 is passed in, it is immutable.
 */
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/**
 Create a session controller with the given NSURLSessionConfiguration. Note that once a configuration
 is passed in, it is immutable.
 */
+ (instancetype)sessionControllerWithConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 Create an NSURLSessionDataTask for the given request. The completion handler will run regardless of
 whether or not the task succeeds or not.
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
 Adds an NSURLSessionTaskDelegate to the given task. Right now, just the HTTPRedirect call and 
 authentication challenge is passed through to the delegate, but future work will pass through 
 all callbacks.
 
 @param delegate The delegate that will respond to NSURLSessionTaskDelegate callbacks
 @param task The task to use the delegate with.
 */
- (void)addNSURLSessionTaskDelegate:(id <NSURLSessionTaskDelegate>)delegate
                            forTask:(NSURLSessionTask *)task;

/**
 Removes the delegate. At this point, the delegate will no longer respond to callbacks.

 @param delegate The delegate to remove.
 */
- (void)removeNSURLSessionTaskDelegate:(id <NSURLSessionTaskDelegate>)delegate;

/**
 @returns The delegate specified in addNSURLSessionTaskDelegate:forTask: by the task parameter.

 @param task The NSURLSessionTask to retrieve the delegate for.
 */
- (id <NSURLSessionTaskDelegate>)NSURLSessionTaskDelegateForTask:(NSURLSessionTask *)task;

@end

@interface CRSessionController (TaskManagement)

/**
 *  Returns the task, if any, associated with the task ID
 *
 *  @param taskId The task ID, called from task.taskIdentifier.
 *
 *  @return The task associated with the taskIdentifier
 */
- (NSURLSessionTask *)taskWithIdentifier:(NSUInteger)taskIdentifier;

/**
 *  A quick way to find out if you have a task with the given identifier.
 *
 *  @param taskIdentifier The task identifier, from task.taskIdentifier
 *
 *  @return Returns YES if the controller has a task with the given taskIdentifier.
 */
- (BOOL)hasTaskWithIdentifier:(NSUInteger)taskIdentifier;

/**
 @returns YES if the task group has any task with the state.
 @param group The name of the task group.
 @param state The state of the NSURLSessionTask to test against.
 */
- (BOOL)hasTasksInGroup:(NSString *)group
              withState:(NSURLSessionTaskState)state;

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

@interface CRSessionController (Reachability)

/**
 Returns YES if any internet connection is reachable.
 */
- (BOOL)isInternetReachable;

/**
 Starts monitoring for reachability changes. If there is a change, the reachability status block will
 be called. Alternatively, you can listen for the kReachabilityChangedNotification NSNotification.
 */
- (void)startReachabilityMonitoring;

/**
 Stops reachability monitoring. Changes in reachability will no longer call the reachability status
 change block, or fire off the kReachabilityChangedNotification NSNotification.
 */
- (void)stopReachabilityMonitoring;

#if TARGET_OS_IOS
/**
 Sets a block that will run every time the network reachability status changes.
 @param block The block to call when the network status changes.
 */
- (void)setReachabilityStatusChangeBlock:(void (^)(NetworkStatus status))block;
#endif

@end

@interface CRSessionController (Debug)

/**
 *  Pretty prints all the current requests both queued and executing
 */
- (void)logRequests;

@end
