//
//  NSURLSession+Courier.m
//  Session
//
//  Created by Andrew Smith on 9/22/13.
//  Copyright (c) 2013 andrewbsmith. All rights reserved.
//

#import "NSURLSession+Courier.h"

@implementation NSURLSession (Courier)

#pragma mark - AFNetworking task stuff

- (NSArray *)tasksForKeyPath:(NSString *)keyPath {
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([keyPath isEqualToString:@"dataTasks"]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:@"uploadTasks"]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:@"downloadTasks"]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:@"tasks"]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return tasks;
}

- (NSArray *)shazam {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

//- (NSArray *)dataTasks {
//    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
//}
//
//- (NSArray *)uploadTasks {
//    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
//}
//
//- (NSArray *)downloadTasks {
//    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
//}

@end
