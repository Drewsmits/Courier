//
//  CourierNSURLSessionTests.m
//  Courier
//
//  Created by Andrew Smith on 8/17/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSMutableURLRequest+Courier.h"
#import "CRTestMacros.h"

@interface CourierNSURLSessionTests : XCTestCase <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@end

@implementation CourierNSURLSessionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testNSURLSessionDataTaskCompetionHandler
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:self
                                                     delegateQueue:nil];
    
    __block BOOL complete = NO;
    __block BOOL success = NO;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"GET"
                                                                     path:@"http://localhost:9000/ping/200"];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            complete = YES;
                                            success = [(NSHTTPURLResponse *)response statusCode] == 200;
                                        }];
    
    [task resume];
    
    WAIT_ON_BOOL(complete);
    
    XCTAssertTrue(success, @"Should be a success");
}

- (void)testNSURLSessionDataTask
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:self
                                                     delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"GET"
                                                                     path:@"http://localhost:9000/ping/200"];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
    
    WAIT_ON_BOOL(task.response == nil);
    
    XCTAssertTrue(NO, @"Should be a success");
}

#pragma mark - NSURLSessionDelegate

/* The task has received a response and no further messages will be
 * received until the completion block is called. The disposition
 * allows you to cancel a request or to turn a data task into a
 * download task. This delegate message is optional - if you do not
 * implement it, you can get the response as a property of the task.
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"response: %@", response);
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    NSLog(@"HERE");
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"HERE");
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSLog(@"HERE");
}

@end
