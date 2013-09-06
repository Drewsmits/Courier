//
//  SessionController.h
//  Session
//
//  Created by Andrew Smith on 8/31/13.
//  Copyright (c) 2013 andrewbsmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionController : NSObject

@property (readonly) NSURLSession *session;

@property (getter = isSuspended) BOOL suspended;

- (NSURLSessionTask *)startTaskForRequestPath:(NSString *)path
                                       method:(NSString *)method
                            completionHandler:(void (^)(NSInteger statusCode, NSData *data, NSURLResponse *response, NSError *error))completionHandler;

- (void)suspend;

- (void)resume;

@end
