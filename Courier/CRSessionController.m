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

#if TARGET_OS_IOS
#import <Reachability/Reachability.h>
#endif

#import "CourierLog.h"
#import "NSURLResponse+Courier.h"
#import "CRSessionDelegate.h"

#define kCRSessionControllerGenericTaskGroup @"kCRSessionControllerGenericTaskGroup"

@interface CRSessionController ()

/**
 *  The keys are the group names, and the values are arrays of associated tasks
 */
@property (nonatomic, strong) NSMutableDictionary *groups;

/**
 *  The keys are a unique string, the value is a dictionary with the task object
 *  and associated group. Tokens are necessary because we don't know the tasks id until it is
 *  created. We have to know which task to remove in the tasks completion block prior to task 
 *  creation. Also, task ids are mutable and can be changed at any time.
 */
@property (nonatomic, strong) NSMutableDictionary *tasksByToken;

/**
 *  The keys are the task IDs, and the values are the associated task object
 */
@property (nonatomic, strong) NSMutableDictionary *tasksByIdentifier;

/**
 
 */
@property (nonatomic, strong) NSMutableDictionary *sessionDelegates;

#if TARGET_OS_IOS
/**
 Internal reachability object
 */
@property (nonatomic, strong) Reachability *reachabilityObject;
#endif

/**
 This is a serial queue used to manage NSURLSessionTasks. This queue is used to ensure that you
 can interact with the CRSessionController in a thread safe way.
 */
@property (nonatomic, strong) NSOperationQueue *serialQueue;

@end

@implementation CRSessionController

- (void)dealloc
{
    [self.session invalidateAndCancel];
}

- (instancetype)init
{
    return [self initWithSessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (self != nil) {
        //
        // Use default session configuration if none provided
        //
        if (configuration == nil) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
    
        //
        // NSURLSession delegate queue
        //
        NSOperationQueue *delegateQueue = [NSOperationQueue new];
        delegateQueue.maxConcurrentOperationCount = 1;
        _sessionDelegateOperationQueue = delegateQueue;
        
        //
        // Build NSURLSession
        //
        CRSessionDelegate *sessionDelegate =
            [CRSessionDelegate sessionDelegateWithSessionController:self];
        _session = [NSURLSession sessionWithConfiguration:configuration
                                                 delegate:sessionDelegate
                                            delegateQueue:_sessionDelegateOperationQueue];
        
        //
        // TODO
        //
        NSOperationQueue *serialQueue = [NSOperationQueue new];
        serialQueue.maxConcurrentOperationCount = 1;
        _serialQueue = serialQueue;

        //
        // Keep track of tasks
        //
        _groups            = [NSMutableDictionary dictionary];
        _tasksByToken      = [NSMutableDictionary dictionary];
        _tasksByIdentifier = [NSMutableDictionary dictionary];
        _sessionDelegates  = [NSMutableDictionary dictionary];
        
#if TARGET_OS_IOS
        //
        // Reachable
        //
        _reachabilityObject = [Reachability reachabilityForInternetConnection];
#endif
    }
    return self;
}

+ (instancetype)sessionControllerWithConfiguration:(NSURLSessionConfiguration *)configuration
{
    return [[self alloc] initWithSessionConfiguration:configuration];
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
                                                 [strongSelf logResponse:response data:data error:error];
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

- (void)logResponse:(NSURLResponse *)response
               data:(NSData *)data
              error:(NSError *)error
{
    CourierLogInfo(@"Finishing task for URL : %@ status code: %li",
                   response.URL,
                   (long)response.cou_statusCode);

#if DEBUG && COURIER_LOG
    NSMutableString *logString = [NSMutableString string];
    
    [logString appendString:@"\n########################################"];
    [logString appendFormat:@"\nResponse: %@", response];
    
    NSString *encodingName = response.textEncodingName;
    NSString *dataString = nil;
    if (encodingName) {
        NSStringEncoding encodingType = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName));
        dataString =  [[NSString alloc] initWithData:data encoding:encodingType];
    }
    
    [logString appendFormat:@"\nData: %@", dataString];
    [logString appendFormat:@"\nError: %@", error];
    [logString appendString:@"\n########################################"];
    
    NSLog(@"%@", logString);
#endif
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

    typeof(self) __weak weakSelf = self;
    [self.serialQueue addOperationWithBlock:^{
        typeof(self) __strong strongSelf = weakSelf;

        NSString *internalGroup = group;
        if (!internalGroup || internalGroup.length == 0) {
            internalGroup = kCRSessionControllerGenericTaskGroup;
        }
        
        CourierLogInfo(@"Adding task to group : %@", group);
        
        //
        // Add task to Groups
        //
        NSMutableArray *tasks = [strongSelf.groups objectForKey:internalGroup];
        if (!tasks) {
            tasks = [NSMutableArray array];
        }
        [tasks addObject:task];
        [strongSelf.groups setObject:tasks
                              forKey:internalGroup];
        
        //
        // Add task to Tasks by token
        //
        NSMutableDictionary *taskDict = [strongSelf.tasksByToken objectForKey:internalGroup];
        if (!taskDict) {
            taskDict = [NSMutableDictionary dictionary];
        }
        taskDict[@"task"] = task;
        taskDict[@"group"] = internalGroup;
        [strongSelf.tasksByToken setObject:taskDict
                                    forKey:token];
        
        //
        // Add task to tasks by id
        //
        [strongSelf.tasksByIdentifier setObject:task
                                         forKey:@(task.taskIdentifier)];
    }];
}

- (void)removeTaskWithToken:(NSString *)token
{
    typeof(self) __weak weakSelf = self;
    [self.serialQueue addOperationWithBlock:^{
        typeof(self) __strong strongSelf = weakSelf;
        NSDictionary     *taskDict = [strongSelf.tasksByToken objectForKey:token];
        NSString         *group    = taskDict[@"group"];
        NSURLSessionTask *task     = taskDict[@"task"];
        
        if (!task) return;
        if (!group || group.length == 0) {
            group = kCRSessionControllerGenericTaskGroup;
        }
        
        //
        // Remove task delegate
        //
        id delegate = [strongSelf NSURLSessionTaskDelegateForTask:task];
        [strongSelf removeNSURLSessionTaskDelegate:delegate];
        
        CourierLogInfo(@"Removing task for URL: %@ in group: %@",
                        task.currentRequest.URL,
                        group);
            
        //
        // Get the tasks
        //
        NSMutableArray *groupTasks = [strongSelf.groups objectForKey:group];
        
        //
        // Remove the task
        //
        [strongSelf.tasksByToken removeObjectForKey:token];
        [strongSelf.tasksByIdentifier removeObjectForKey:@(task.taskIdentifier)];
        [groupTasks removeObject:task];
        
        //
        // If empty, remove tasks array
        //
        if (groupTasks.count == 0) {
            [strongSelf.groups removeObjectForKey:group];
        }
    }];
}

- (void)addNSURLSessionTaskDelegate:(id <NSURLSessionTaskDelegate>)delegate
                            forTask:(NSURLSessionTask *)task
{
	NSParameterAssert(delegate);
	NSParameterAssert(task);
	if (delegate == nil || task == nil) return;
	@synchronized(_sessionDelegates)	{
		[_sessionDelegates setObject:delegate
		                      forKey:[NSValue valueWithNonretainedObject:task]];
	}
}

- (void)removeNSURLSessionTaskDelegate:(id <NSURLSessionTaskDelegate>)delegate
{
    if (delegate == nil) return;
    @synchronized(_sessionDelegates) {
        __block id taskKey;
        [_sessionDelegates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isEqual:delegate]) {
                taskKey = key;
                *stop = YES;
            }
        }];
        [_sessionDelegates removeObjectForKey:taskKey];
    }
}

- (id <NSURLSessionTaskDelegate>)NSURLSessionTaskDelegateForTask:(NSURLSessionTask *)task
{
    return [_sessionDelegates objectForKey:[NSValue valueWithNonretainedObject:task]];
}

@end

@implementation CRSessionController (TaskManagement)

- (NSURLSessionTask *)taskWithIdentifier:(NSUInteger)taskIdentifier
{
    return [_tasksByIdentifier objectForKey:@(taskIdentifier)];
}

- (BOOL)hasTaskWithIdentifier:(NSUInteger)taskIdentifier
{
    return [_tasksByIdentifier objectForKey:@(taskIdentifier)] != nil;
}

- (BOOL)hasTasksInGroup:(NSString *)group
              withState:(NSURLSessionTaskState)state
{
    __block BOOL result = NO;
    typeof(self) __weak weakSelf = self;
    NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSArray *groupTasks = weakSelf.groups[group];
        for (NSURLSessionTask *task in groupTasks) {
            if (task.state == state) {
                result = YES;
                return;
            }
        }
    }];
    
    [self.serialQueue addOperations:@[op]
                  waitUntilFinished:YES];

    return result;
}

- (void)suspendTasksInGroup:(NSString *)group
{
    typeof(self) __weak weakSelf = self;
    [self.serialQueue addOperationWithBlock:^{
        typeof(self) __strong strongSelf = weakSelf;
        CourierLogInfo(@"Suspend tasks in group : %@", group);
        NSArray *tasks = [strongSelf.groups valueForKey:group];
        for (NSURLSessionTask *task in tasks) {
            [task suspend];
        }
    }];
}

- (void)resumeTasksInGroup:(NSString *)group
{
    typeof(self) __weak weakSelf = self;
    [self.serialQueue addOperationWithBlock:^{
        typeof(self) __strong strongSelf = weakSelf;
        CourierLogInfo(@"Resume tasks in group : %@", group);
        NSArray *tasks = [strongSelf.groups valueForKey:group];
        for (NSURLSessionTask *task in tasks) {
            [task resume];
        }
    }];
}

- (void)cancelTasksInGroup:(NSString *)group
{
    typeof(self) __weak weakSelf = self;
    [self.serialQueue addOperationWithBlock:^{
        typeof(self) __strong strongSelf = weakSelf;
        CourierLogInfo(@"Canceling tasks in group : %@", group);
        NSArray *tasks = [strongSelf.groups valueForKey:group];
        for (NSURLSessionTask *task in tasks) {
            [task cancel];
        }
    }];
}

- (void)suspendAllTasks
{
    typeof(self) __weak weakSelf = self;
    [self.serialQueue addOperationWithBlock:^{
        typeof(self) __strong strongSelf = weakSelf;
        CourierLogInfo(@"Suspend all tasks");
        for (NSString *groupName in strongSelf.groups.allKeys) {
            [strongSelf suspendTasksInGroup:groupName];
        }
    }];
}

- (void)resumeAllTasks
{
    typeof(self) __weak weakSelf = self;
    [self.serialQueue addOperationWithBlock:^{
        typeof(self) __strong strongSelf = weakSelf;
        CourierLogInfo(@"Resume all tasks");
        for (NSString *groupName in strongSelf.groups.allKeys) {
            [strongSelf resumeTasksInGroup:groupName];
        }
    }];
}

- (void)cancelAllTasks
{
    typeof(self) __weak weakSelf = self;
    [self.serialQueue addOperationWithBlock:^{
        typeof(self) __strong strongSelf = weakSelf;
        CourierLogInfo(@"Cancel all tasks");
        for (NSString *groupName in strongSelf.groups.allKeys) {
            [strongSelf cancelTasksInGroup:groupName];
        }
    }];
}

@end

#if TARGET_OS_IOS

@implementation CRSessionController (Reachability)

- (BOOL)isInternetReachable
{
    return _reachabilityObject.isReachable;
}

- (void)startReachabilityMonitoring
{
    [_reachabilityObject startNotifier];
}

- (void)stopReachabilityMonitoring
{
    [_reachabilityObject stopNotifier];
}

- (void)setReachabilityStatusChangeBlock:(void (^)(NetworkStatus status))block
{
    _reachabilityObject.reachableBlock = ^(Reachability *reachability) {
        if (block) {
            block(reachability.currentReachabilityStatus);
        }
    };
    
    _reachabilityObject.unreachableBlock = ^(Reachability *reachability) {
        if (block) {
            block(reachability.currentReachabilityStatus);
        }
    };
}

@end

#endif

@implementation CRSessionController (Debug)

- (void)logRequests
{
    CourierLogInfo(@"Log current tasks:");
    NSArray *tasks = _tasksByIdentifier.allValues;
    for (NSURLSessionTask *task in tasks) {
        __unused NSString *description = [NSString stringWithFormat:@"task: %@\n URL: %@\nMethod: %@",
                                          task,
                                          task.currentRequest.URL,
                                          task.currentRequest.HTTPMethod];
        CourierLogInfo(@"%@", description);
    }
}

@end
