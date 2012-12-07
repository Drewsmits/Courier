
//  CRHTTPRequestOperation.m
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
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
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
//

#import "CRRequestOperation.h"

#pragma mark - State


#pragma mark - Private

@interface CRRequestOperation ()

- (void)startConnection;

@property (nonatomic, copy) CRRequestOperationSuccessBlock success;
@property (nonatomic, copy) CRRequestOperationFailureBlock failure;

@end

#pragma mark -

@implementation CRRequestOperation

static NSThread *_networkRequestThread = nil;

+ (id)operationWithRequest:(CRRequest *)request 
                   success:(CRRequestOperationSuccessBlock)successBlock
                   failure:(CRRequestOperationFailureBlock)failureBlock
{    
    CRRequestOperation *op = [CRRequestOperation new];
    
    op.request    = request;
    op.success    = successBlock;
    op.failure    = failureBlock;
        
    return op;
}

#pragma mark - Threading

+ (void)networkRequestThreadEntryPoint:(id)object
{
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    } while (YES);
}

+ (NSThread *)networkRequestThread
{
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

- (void)start
{
    @autoreleasepool {
        [super start];
        
        [self performSelector:@selector(startConnection) 
                     onThread:[[self class] networkRequestThread] 
                   withObject:nil 
                waitUntilDone:YES 
                        modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    }
}

- (void)startConnection
{
    self.connection = [[NSURLConnection alloc] initWithRequest:[self.request URLRequest]
                                                       delegate:self 
                                               startImmediately:NO];
    
    [self.connection start];
}

- (void)finish
{    
    if(_connection) {
        [self.connection cancel];
        _connection = nil;
    }

    if (self.response.success) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.success(self.request, self.response);
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            BOOL unreachable = NO;
            NSError *error = nil;
            if (self.response) {
                error = [NSError errorWithDomain:@"com.courier.cdrequestoperation" 
                                            code:self.response.statusCode 
                                        userInfo:[NSDictionary dictionaryWithObject:self.response.statusCodeDescription 
                                                                             forKey:NSLocalizedFailureReasonErrorKey]];
            } else {
                error = [NSError errorWithDomain:@"com.courier.cdrequestoperation" 
                                            code:0 
                                        userInfo:[NSDictionary dictionaryWithObject:@"Connection not reachable" 
                                                                             forKey:NSLocalizedFailureReasonErrorKey]];
                unreachable = YES;
            }
                                    
            if (self.failure) {
                self.failure(self.request, self.response, error, unreachable);
            }
        });
    }
    
    [super finish];
}

- (void)cancel
{
    [super cancel];
    [self.connection cancel];
}

#pragma mark - NSURLConnection Data

- (NSURLRequest *)connection:(NSURLConnection *)connection 
             willSendRequest:(NSURLRequest *)request 
            redirectResponse:(NSURLResponse *)response
{
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{    
    NSInteger capacity = MIN(MAX(abs(response.expectedContentLength), 1024), 1024 * 1024 * 8);
    
    self.response = [CRResponse responseWithResponse:response 
                                         andCapacity:capacity];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.response.data appendData:data]; 
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DLog(@"Connection failed!  URL: %@  Response: %@", self.request.path, self.response.responseDescription);
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
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
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
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

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return NO;
}

@end
