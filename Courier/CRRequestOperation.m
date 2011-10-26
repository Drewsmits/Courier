//
//  CRHTTPRequestOperation.m
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import "CRRequestOperation.h"

#pragma mark - State


#pragma mark - Private

@interface CRRequestOperation ()
@property (readwrite, nonatomic, retain) NSURLConnection *connection;
@property (readwrite, nonatomic, retain) CRRequest *request;
@property (readwrite, nonatomic, retain) CRResponse *response;
@property (readwrite, nonatomic, copy) CRRequestOperationSuccessBlock success;
@property (readwrite, nonatomic, copy) CRRequestOperationFailureBlock failure;
@end

#pragma mark -

@implementation CRRequestOperation

static NSThread *_networkRequestThread = nil;

@synthesize connection = _connection,
            request = _request,
            response = _response,
            success,
            failure;

- (void)dealloc {
    [_connection release];
    [_request release];
    [_response release];
    
    [super dealloc];
}


+ (id)operationWithRequest:(CRRequest *)request 
                   success:(CRRequestOperationSuccessBlock)successBlock
                   failure:(CRRequestOperationFailureBlock)failureBlock {    
    
    CRRequestOperation *op = [CRRequestOperation operation];
   
    op.request = request;
    op.request = request;
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

- (void)start {
    
    [self performSelector:@selector(startConnection) 
                 onThread:[[self class] networkRequestThread] 
               withObject:nil 
            waitUntilDone:YES 
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
}

- (void)startConnection {
    self.connection = [[[NSURLConnection alloc] initWithRequest:[self.request URLRequest]
                                                       delegate:self 
                                               startImmediately:NO] autorelease];
    
    [self.connection start];
}

- (void)finish {
    if(self.connection) {
        [self.connection cancel];
        [_connection release];
        _connection = nil;
    }
   
    [super finish];
}

#pragma mark - NSURLConnection Data

- (NSURLRequest *)connection:(NSURLConnection *)connection 
             willSendRequest:(NSURLRequest *)request 
            redirectResponse:(NSURLResponse *)response {
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSInteger capacity = MIN(MAX(abs(response.expectedContentLength), 1024), 1024 * 1024 * 8);
    
    self.response = [CRResponse responseWithResponse:response 
                                         andCapacity:capacity];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.response.data appendData:data]; 
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.failure(self.request, self.response, error);
    });
    
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.success(self.request, self.response);
    });
    
    [self finish];
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

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection 
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

#pragma mark - NSURLConnection Authentication

//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    NSLog(@"auth challenge");
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    NSLog(@"auth challenge");
//}
//
//- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    NSLog(@"auth challenge");
//}

//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    
//}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return NO;
}

@end
