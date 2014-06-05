//
//  CRURLProtocol.m
//  Courier
//
//  Created by Andrew Smith on 6/5/14.
//  Copyright (c) 2014 Andrew B. Smith. All rights reserved.
//

#import "CRURLProtocol.h"

static CGFloat _responseDelay = 0.0f;
static NSInteger _responseStatusCode = 200;
static NSData *_responseData = nil;
static NSDictionary *_globalResponseHeaders = nil;
static NSURLCacheStoragePolicy _cacheStoragePolicy = NSURLCacheStorageNotAllowed;

@implementation CRURLProtocol

#pragma mark - Global Settings

+ (void)resetGlobalSettings
{
    _responseDelay = 0.0f;
    _responseStatusCode = 200;
    _responseData = nil;
    _globalResponseHeaders = @{@"Content-Type": @"application/json"};
    _cacheStoragePolicy = NSURLCacheStorageNotAllowed;
}

+ (void)setGlobalResponseDelay:(CGFloat)delay
{
    _responseDelay = delay;
}

+ (void)setGlobalResponseStatusCode:(NSInteger)code
{
    _responseStatusCode = code;
}

+ (void)setGlobalResponseJson:(id)json
{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:json
                                                   options:0
                                                     error:&error];
    if (error) {
        NSLog(@"Error setting response JSON: %@", error);
    } else {
        _responseData = data;
    }
}

+ (void)setGlobalResponseData:(NSData *)data
{
    _responseData = data;
}

+ (void)setGlobalCacheStoragePolicy:(NSURLCacheStoragePolicy)policy
{
    _cacheStoragePolicy = policy;
}

#pragma mark - NSURLProtocol

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return YES;
}

- (void)startLoading
{
    //
    // Grab the client
    //
    id <NSURLProtocolClient> client = self.client;
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:_responseStatusCode
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:_globalResponseHeaders];
    
    execute_after(_responseDelay, ^{
        [client URLProtocol:self
         didReceiveResponse:response
         cacheStoragePolicy:_cacheStoragePolicy];
        
        //
        // Add the JSON response
        //
        [client URLProtocol:self
                didLoadData:_responseData];
        
        //
        // Finish up
        //
        [client URLProtocolDidFinishLoading:self];
    });
}

- (void)stopLoading
{
    
}

#pragma mark -

static void execute_after(CGFloat delayInSeconds, dispatch_block_t block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

@end
