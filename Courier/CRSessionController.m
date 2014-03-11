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

@property (nonatomic, weak) id <CRURLSessionControllerDelegate> controllerDelegate;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableDictionary *groups;

@property (nonatomic, strong) NSMutableDictionary *tasks;

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

#pragma mark - Task

- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                           completionHandler:(void (^)(NSData *data,
                                                       NSURLResponse *response,
                                                       NSError *error))completionHandler
{
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data,
                                                                 NSURLResponse *response,
                                                                 NSError *error) {
                                                 __strong typeof(self) strongSelf = weakSelf;
                                                 [strongSelf handleResponse:response];
                                                 if (completionHandler) completionHandler(data, response, error);
                                             }];
    return task;
}

- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                                   taskGroup:(NSString *)group
                           completionHandler:(void (^)(NSData *data,
                                                       NSURLResponse *response,
                                                       NSError *error))completionHandler
{
    //
    // Unique task token
    //
    NSString *token = [self uniqueToken];
    
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
                                                 if (completionHandler) completionHandler(data, response, error);
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

#pragma mark - Task Management

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
    
    CourierLogInfo(@"Adding task to group : %@", group);
    
    //
    // Groups
    //
    NSMutableArray *tasks = [_groups objectForKey:group];
    if (!tasks) {
        tasks = [NSMutableArray array];
        [_groups setObject:tasks forKey:group];
    }
    [tasks addObject:task];
    
    //
    // Tasks
    //
    NSMutableDictionary *taskDict = [_tasks objectForKey:group];
    if (!taskDict) {
        taskDict = [NSMutableDictionary dictionary];
        [_tasks setObject:taskDict forKey:token];
    }
    taskDict[@"task"] = task;
    taskDict[@"group"] = group;
}

- (void)removeTaskWithToken:(NSString *)token
{
    NSDictionary     *taskDict = [_tasks objectForKey:token];
    NSString         *group    = taskDict[@"group"];
    NSURLSessionTask *task     = taskDict[@"task"];
    
    // Remove from tasks
    [_tasks removeObjectForKey:token];
    
    // Remove from groups
    [self removeTask:task fromGroup:group];
}

- (void)removeTask:(NSURLSessionTask *)task
         fromGroup:(NSString *)group
{
    if (!task) return;
    if (!group || group.length == 0) {
        group = kCRSessionControllerGenericTaskGroup;
    }
    
    CourierLogInfo(@"Removing task from group : %@", group);
    
    //
    // Get the tasks
    //
    NSMutableArray *tasks = [_groups objectForKey:group];
    
    //
    // Remove the task
    //
    [tasks removeObject:task];
    
    //
    // If empty, remove tasks array
    //
    if (tasks.count == 0) {
        [_groups removeObjectForKey:group];
    }
}

#pragma mark - Task State Management

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
    // Observer changes to the NSURLSession delegateQueue operation count.
    // This provides global control of the network activity indicator
    if ([keyPath isEqualToString:@"delegateQueue.operationCount"]
        && [object isEqual:_session]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = (_session.delegateQueue.operationCount > 0);
    }
}

@end
