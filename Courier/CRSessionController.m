//
//  CRSessionController.m
//  Courier
//
//  Created by Andrew Smith on 9/22/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "CRSessionController.h"

#import "CRTaskHandler.h"

@interface CRSessionController ()

@property (strong) NSOperationQueue *delegateQueue;

@property (strong) NSURLSessionConfiguration *sessionConfig;

@property (nonatomic, readwrite, strong) NSURLSession *session;

@end

@implementation CRSessionController

- (instancetype)initWithSession:(NSURLSession *)session
{
    self = [super init];
    if (self) {
        _session = session;
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
didBecomeInvalidWithError:(NSError *)error
{
    
}

- (void)URLSession:(NSURLSession *)Session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    CRTaskHandler *taskHandler = [self taskHandlerForTask:task];
    
    if (taskHandler && taskHandler.completionHandler) {
        taskHandler.completionHandler(session, task, error);
    }
    
    [self removeHandlerForTask:task];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *))completionHandler
{
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;
{
    CRTaskHandler *taskHandler = [self taskHandlerForTask:dataTask];
    if (taskHandler && taskHandler.didRecieveDataHandler) {
        taskHandler.didRecieveDataHandler(session, dataTask, data);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    
}

//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
// willCacheResponse:(NSCachedURLResponse *)proposedResponse
// completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
//{
//    
//}

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

- (void)removeHandlerForTask:(NSURLSessionTask *)task
{
    NSString *taskKey = [NSString stringWithFormat:@"%i", task.taskIdentifier];
    @synchronized (self.taskHandlers) {
        NSLog(@"Remove task with ID : %@", taskKey);
        [self.taskHandlers removeObjectForKey:taskKey];
    }
}

#pragma mark - Task

- (CRTaskHandler *)taskHandlerForTask:(NSURLSessionTask *)task
{
    NSString *taskKey = [NSString stringWithFormat:@"%i", task.taskIdentifier];
    return (CRTaskHandler *)[self.taskHandlers valueForKey:taskKey];
}

- (NSString *)taskKeyForTask:(NSURLSessionTask *)task
{
    return [NSString stringWithFormat:@"%i", task.taskIdentifier];
}

@end
