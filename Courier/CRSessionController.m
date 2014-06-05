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

#define kCRSessionControllerGenericTaskGroup @"kCRSessionControllerGenericTaskGroup"

@interface CRSessionController ()

@property (nonatomic, weak, readwrite) id <CRURLSessionControllerDelegate> controllerDelegate;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableDictionary *groups;

@property (nonatomic, strong) NSMutableDictionary *tasks;

@property (nonatomic, strong) Reachability *reachabilityObject;

@property (nonatomic, assign) NSUInteger busyCount;

@end

@implementation CRSessionController

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
    // Keep track of tasks
    //
    controller.groups = [NSMutableDictionary dictionary];
    controller.tasks  = [NSMutableDictionary dictionary];

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
    
    return controller;
}

#pragma mark - Task creation

- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                           completionHandler:(void (^)(NSData *data,
                                                       NSURLResponse *response,
                                                       BOOL cachedResponse,
                                                       NSError *error))completionHandler
{
    NSURLSessionDataTask *task = [self dataTaskForRequest:request
                                                taskGroup:nil
                                        completionHandler:completionHandler];
    return task;
}

- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                                   taskGroup:(NSString *)group
                           completionHandler:(void (^)(NSData *data,
                                                       NSURLResponse *response,
                                                       BOOL cachedResponse,
                                                       NSError *error))completionHandler
{
    CourierLogInfo(@"Creating task for URL : %@", request.URL);
    
    //
    // Unique task token
    //
    NSString *token = [self uniqueToken];
    
    //
    // Check for cached response. Pass this into the completion and allow the task
    // to pass through the normal delegate queue flow.
    //
    NSURLCache *urlCache = _session.configuration.URLCache;
    BOOL cachedResponse = urlCache && [urlCache cachedResponseForRequest:request];
        
    //
    // Create Task
    //
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data,
                                                                 NSURLResponse *response,
                                                                 NSError *error) {
                                                 __strong typeof(self) strongSelf = weakSelf;
                                                 [strongSelf handleResponse:response];
                                                 [strongSelf removeTaskWithToken:token];
                                                 if (completionHandler) completionHandler(data,
                                                                                          response,
                                                                                          cachedResponse,
                                                                                          error);
                                             }];
    
    //
    // Keep track of the task
    //
    [self addTask:task
        withToken:token
          toGroup:group];
    
    return task;
}

- (void)handleResponse:(NSURLResponse *)response
{
    CourierLogInfo(@"URL: %@, status code: %li",
                   response.URL,
                   (long)response.statusCode);
    
    //
    // Pass through response to delegate
    //
    if ([_controllerDelegate respondsToSelector:@selector(sessionController:didRecieveResponse:)]) {
        [_controllerDelegate sessionController:self
                            didRecieveResponse:response];
    }
    
    //
    // Simple hook to respond to 401 responses
    //
    if (response.statusCode == 401) {
        [_controllerDelegate sessionReceivedUnauthorizedResponse:response];
    }
}

- (NSURLSessionConfiguration *)configuration
{
    return _session.configuration;
}

#pragma mark - Add/Remove Tasks

- (NSString *)uniqueToken
{
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void)addTask:(NSURLSessionTask *)task
      withToken:(NSString *)token
        toGroup:(NSString *)group
{
    if (!task) return;
    if (!group || group.length == 0) {
        group = kCRSessionControllerGenericTaskGroup;
    }
    @synchronized (self) {
        CourierLogInfo(@"Adding task to group : %@", group);
        
        //
        // Add task to Groups
        //
        NSMutableArray *tasks = [_groups objectForKey:group];
        if (!tasks) {
            tasks = [NSMutableArray array];
        }
        [tasks addObject:task];
        [_groups setObject:tasks forKey:group];
        
        //
        // Add task to reverse map Tasks
        //
        NSMutableDictionary *taskDict = [_tasks objectForKey:group];
        if (!taskDict) {
            taskDict = [NSMutableDictionary dictionary];
        }
        taskDict[@"task"] = task;
        taskDict[@"group"] = group;
        [_tasks setObject:taskDict forKey:token];
        
        //
        // Observe task state for network activity indicator
        //
        [task addObserver:self
               forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
}

- (void)removeTaskWithToken:(NSString *)token
{
    NSDictionary     *taskDict = [_tasks objectForKey:token];
    NSString         *group    = taskDict[@"group"];
    NSURLSessionTask *task     = taskDict[@"task"];
    
    if (!task) return;
    if (!group || group.length == 0) {
        group = kCRSessionControllerGenericTaskGroup;
    }
    
    @synchronized (self) {
        CourierLogInfo(@"Removing task for URL: %@ in group: %@",
                       task.currentRequest.URL,
                       group);
        
        //
        // Get the tasks
        //
        NSMutableArray *groupTasks = [_groups objectForKey:group];
        
        //
        // Remove the task
        //
        [_tasks removeObjectForKey:token];
        [groupTasks removeObject:task];
        
        //
        // If empty, remove tasks array
        //
        if (groupTasks.count == 0) {
            [_groups removeObjectForKey:group];
        }
        
        //
        // Stop observing task state
        //
        [task removeObserver:self
                  forKeyPath:@"state"];
    }
}

#pragma mark - Reachability

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
    //
    // Task state observing
    //
    if ([keyPath isEqualToString:@"state"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURLSessionTask *task = (NSURLSessionTask *)object;
            switch (task.state) {
                case NSURLSessionTaskStateRunning:
                    self.busyCount += 1;
                    break;
                case NSURLSessionTaskStateSuspended:
                    self.busyCount -= 1;
                    break;
                case NSURLSessionTaskStateCanceling:
                    // noop
                    break;
                case NSURLSessionTaskStateCompleted:
                    self.busyCount -= 1;
                    break;
                default:
                    break;
            }
            if (self.busyCount > 1) return;
            BOOL busy = self.busyCount > 0;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = busy;
        });
    }
}

@end

@implementation CRSessionController (TaskManagement)

- (void)suspendTasksInGroup:(NSString *)group
{
    CourierLogInfo(@"Suspend tasks in group : %@", group);
    NSArray *tasks = [_groups valueForKey:group];
    for (NSURLSessionTask *task in tasks) {
        [task suspend];
    }
}

- (void)resumeTasksInGroup:(NSString *)group
{
    CourierLogInfo(@"Resume tasks in group : %@", group);
    NSArray *tasks = [_groups valueForKey:group];
    for (NSURLSessionTask *task in tasks) {
        [task resume];
    }
}

- (void)cancelTasksInGroup:(NSString *)group
{
    CourierLogInfo(@"Canceling tasks in group : %@", group);
    NSArray *tasks = [_groups valueForKey:group];
    for (NSURLSessionTask *task in tasks) {
        [task cancel];
    }
}

- (void)suspendAllTasks
{
    CourierLogInfo(@"Suspend all tasks");
    __weak typeof(self) weakSelf = self;
    [_groups enumerateKeysAndObjectsUsingBlock:^(NSString *groupName,
                                                 NSArray *tasks,
                                                 BOOL *stop) {
        [weakSelf suspendTasksInGroup:groupName];
    }];
}

- (void)resumeAllTasks
{
    CourierLogInfo(@"Resume all tasks");
    __weak typeof(self) weakSelf = self;
    [_groups enumerateKeysAndObjectsUsingBlock:^(NSString *groupName,
                                                 NSArray *tasks,
                                                 BOOL *stop) {
        [weakSelf resumeTasksInGroup:groupName];
    }];
}

- (void)cancelAllTasks
{
    CourierLogInfo(@"Cancel all tasks");
    __weak typeof(self) weakSelf = self;
    [_groups enumerateKeysAndObjectsUsingBlock:^(NSString *groupName,
                                                 NSArray *tasks,
                                                 BOOL *stop) {
        [weakSelf cancelTasksInGroup:groupName];
    }];
}

@end

@implementation CRSessionController (Debug)

- (void)logRequests
{
    CourierLogInfo(@"Log current tasks:");
    for (NSURLSessionTask *task in _tasks) {
        NSString *description = [NSString stringWithFormat:@"task: %@\n URL: %@\nMethod: %@", task, task.currentRequest.URL, task.currentRequest.HTTPMethod];
        CourierLogInfo(@"%@", description);
    }
}

@end
