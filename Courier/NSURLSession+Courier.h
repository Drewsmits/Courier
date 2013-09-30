//
//  NSURLSession+Courier.h
//  Session
//
//  Created by Andrew Smith on 9/22/13.
//  Copyright (c) 2013 andrewbsmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (Courier)

/**
 The data, upload, and download tasks currently run by the managed session.
 */
//@property (readonly) NSArray *tasks;

- (NSArray *)shazam;

///**
// The data tasks currently run by the managed session.
// */
//@property (readonly) NSArray *dataTasks;
//
///**
// The upload tasks currently run by the managed session.
// */
//@property (readonly) NSArray *uploadTasks;
//
///**
// The download tasks currently run by the managed session.
// */
//@property (readonly) NSArray *downloadTasks;

@end
