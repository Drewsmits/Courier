//
//  CRSessionController.m
//  Courier
//
//  Created by Andrew Smith on 9/22/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CRSessionController.h"

#import "NSURLSession+Courier.h"
#import "CRTaskHandler.h"
#import "NSURLSessionTask+Courier.h"

@interface CRSessionController ()

@property (strong) NSOperationQueue *delegateQueue;

@property (strong) NSURLSessionConfiguration *sessionConfig;

@property (nonatomic, readwrite, strong) NSURLSession *session;

@end

@implementation CRSessionController

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (self) {
        _delegateQueue = [NSOperationQueue new];
        [_delegateQueue setMaxConcurrentOperationCount:1];
        
        if (!configuration) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        _sessionConfig = configuration;
        
        // Session
        _session = [NSURLSession sessionWithConfiguration:_sessionConfig
                                                 delegate:self
                                            delegateQueue:_delegateQueue];
        
        // Task handlers
        _taskHandlers = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
                                    delegate:(id <NSURLSessionDelegate>)sessionDelegate
                               delegateQueue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        _delegateQueue = queue;
        
        if (!configuration) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        _sessionConfig = configuration;
        
        // Session
        _session = [NSURLSession sessionWithConfiguration:_sessionConfig
                                                 delegate:sessionDelegate
                                            delegateQueue:_delegateQueue];
    }
    return self;
}

- (NSURLSessionDataTask *)dataTaskForRequest:(NSURLRequest *)request
                                 taskHandler:(CRTaskHandler *)handler
{
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    
    [self addTaskHandler:handler
               forTaskId:[NSString stringWithFormat:@"%i", task.taskIdentifier]];
    
    return task;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;
{
    NSString *taskId = [NSString stringWithFormat:@"%i", dataTask.taskIdentifier];
    
    CRTaskHandler *taskHandler = (CRTaskHandler *)[self.taskHandlers valueForKey:taskId];
    
    if (taskHandler && taskHandler.didRecieveDataHandler) {
        taskHandler.didRecieveDataHandler(session, dataTask, data);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    CRTaskHandler *taskHandler = (CRTaskHandler *)[self.taskHandlers valueForKey:task.taskIdentifierKey];

    if (taskHandler && taskHandler.completionHandler) {
        taskHandler.completionHandler(session, task, error);
    }
    
    [self removeTaskHandlerForTaskId:task.taskIdentifierKey];
}

#pragma mark - Task Handlers

- (void)addTaskHandler:(CRTaskHandler *)taskHandler
             forTaskId:(NSString *)taskId
{
    @synchronized (self.taskHandlers) {
        NSLog(@"Add task with ID : %@", taskId);
        [self.taskHandlers setObject:taskHandler
                              forKey:taskId];
    }
}

- (void)removeTaskHandlerForTaskId:(NSString *)taskId
{
    @synchronized (self.taskHandlers) {
        NSLog(@"Remove task with ID : %@", taskId);
        [self.taskHandlers removeObjectForKey:taskId];
    }
}

@end
