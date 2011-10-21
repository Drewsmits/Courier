//
//  CRHTTPRequestOperation.m
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import "CRRequestOperation.h"

@interface CRRequestOperation ()
@property (readwrite, nonatomic, retain) NSURLConnection *connection;
@property (readwrite, nonatomic, retain) CRRequest *request;
@property (readwrite, nonatomic, retain) CRResponse *response;
@property (readwrite, nonatomic, copy) CRRequestOperationSuccessBlock success;
@property (readwrite, nonatomic, copy) CRRequestOperationFailureBlock failure;
@end

@implementation CRRequestOperation

static NSThread *_networkRequestThread = nil;

@synthesize connection,
            request,
            response,
            success,
            failure;

- (void)dealloc {
    [connection release];
    [request release];
    [response release];
    
    [super dealloc];
}

- (id)initWithRequest:(CRRequest *)aRequest {
    if (self = [super init]) {
        self.request = request;
    }
    return self;
}

+ (id)operationWithRequest:(CRRequest *)aRequest 
                   success:(CRRequestOperationSuccessBlock)successBlock
                   failure:(CRRequestOperationFailureBlock)failureBlock {    
    
    CRRequestOperation *op = [[[CRRequestOperation alloc] initWithRequest:aRequest] autorelease];
    
    op.request = aRequest;
    op.success = successBlock;
    op.failure = failureBlock;
    
    return op;
}

#pragma mark - Threading

+ (void)networkRequestThreadEntryPoint:(id)object {
    do {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [[NSRunLoop currentRunLoop] run];
        [pool drain];
    } while (YES);
}

+ (NSThread *)networkRequestThread {
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self 
                                                        selector:@selector(networkRequestThreadEntryPoint:) 
                                                          object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

#pragma mark - NSOperation

- (void)startConnection {
    self.connection = [[[NSURLConnection alloc] initWithRequest:[self.request URLRequest]
                                                       delegate:self 
                                               startImmediately:NO] autorelease];
    
    [self.connection start];
}

- (void)start {
    
    // Ensure that this operation starts on the main thread
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start)
                               withObject:nil 
                            waitUntilDone:NO];
        return;
    }
    
    [self performSelector:@selector(startConnection) 
                 onThread:[[self class] networkRequestThread] 
               withObject:nil 
            waitUntilDone:YES 
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    
//    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (backgroundTask != UIBackgroundTaskInvalid) {
//                    [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
//                    backgroundTask = UIBackgroundTaskInvalid;
//                    [self cancel];
//                }
//            });
//        }];
    
}

- (BOOL)isReady {
    return YES;
}
//
//- (BOOL)isExecuting {
//    return NO;
//}
//
//- (BOOL)isFinished {
//    return NO;
//}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark - NSURLConnection Data


//- (NSURLRequest *)connection:(NSURLConnection *)connection 
//             willSendRequest:(NSURLRequest *)request 
//            redirectResponse:(NSURLResponse *)response {
//    
//}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse {
    self.response = [CRResponse responseWithResponse:aResponse];
    NSLog(@"response: %@", [self.response statusCodeDescription]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.failure(self.request, self.response, error);
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.success(self.request, self.response);
    });
}

//- (NSInputStream *)connection:(NSURLConnection *)connection 
//            needNewBodyStream:(NSURLRequest *)request {
//    
//}

//- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten 
//                                               totalBytesWritten:(NSInteger)totalBytesWritten 
//                                       totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
//    
//}

//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection 
//                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
//
//}

#pragma mark - NSURLConnection Authentication

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
}

//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    
//}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return NO;
}

@end
