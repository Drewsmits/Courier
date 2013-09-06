//
//  SessionController.m
//  Session
//
//  Created by Andrew Smith on 8/31/13.
//  Copyright (c) 2013 andrewbsmith. All rights reserved.
//

#import "SessionController.h"
#import <Courier/NSMutableURLRequest+Courier.h>

@interface SessionController () <NSURLSessionDataDelegate>

@property (strong) NSOperationQueue *delegateQueue;

@property (strong) NSURLSessionConfiguration *sessionConfig;

@property (strong) NSURLSession *session;

@property (strong) NSMutableDictionary *tasks;

@end

@implementation SessionController

- (id)init
{
    self = [super init];
    if (self) {
        // Serial Delegate queue
        _delegateQueue = [NSOperationQueue new];
        [_delegateQueue setMaxConcurrentOperationCount:1];
        
        // Default session config
        _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // Session
        _session = [NSURLSession sessionWithConfiguration:_sessionConfig
                                                 delegate:self
                                            delegateQueue:_delegateQueue];
        
        _tasks = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark -

- (NSURLSessionTask *)startTaskForRequestPath:(NSString *)path
                                       method:(NSString *)method
                            completionHandler:(void (^)(NSInteger statusCode, NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    //
    // Bail if duplicate task
    //
    if ([self.tasks objectForKey:path]) {
        return nil;
    }
    
    //
    // Build request
    //
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:method
                                                                     path:path];
    
    //
    // Build task
    //
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 if (completionHandler) {
                                                     completionHandler([(NSHTTPURLResponse *)response statusCode],
                                                                       data,
                                                                       response,
                                                                       error);
                                                 }
                                                 [self taskForPathFinished:path];
                                             }];
    
    //
    // Store task for later
    //
    @synchronized (self.tasks) {
        [self.tasks setObject:task
                       forKey:path];
    }
    
    //
    // Start task
    //
    if (!self.isSuspended) {
        [task resume];
    }
    
    return task;
}

- (void)taskForPathFinished:(NSString *)path
{
    @synchronized (self.tasks) {
        [self.tasks removeObjectForKey:path];
    }
}

#pragma mark -

- (void)suspend
{
    _suspended = YES;
    [self enumerateTasksWithBlock:^(NSURLSessionTask *task) {
        [task suspend];
    }];
}

- (void)resume
{
    _suspended = NO;
    [self enumerateTasksWithBlock:^(NSURLSessionTask *task) {
        [task resume];
    }];
}

#pragma mark - 

- (void)enumerateTasksWithBlock:(void (^)(NSURLSessionTask *task))block
{
    [self.tasks enumerateKeysAndObjectsUsingBlock:^(NSString *path,
                                                    NSURLSessionTask *task,
                                                    BOOL *stop) {
        if (block) {
            block(task);
        }
    }];
}

@end
