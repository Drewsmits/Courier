//
//  NSURLResponse+Courier.m
//  Courier
//
//  Created by Andrew Smith on 8/31/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "NSURLResponse+Courier.h"

@implementation NSURLResponse (Courier)

- (NSInteger)statusCode
{
    return [(NSHTTPURLResponse *)self statusCode];
}

- (BOOL)success
{
    NSInteger statusCode = [(NSHTTPURLResponse *)self statusCode];
    return (statusCode >= 200 && statusCode < 300);
}

@end
