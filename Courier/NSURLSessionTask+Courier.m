//
//  NSURLSessionTask+Courier.m
//  Courier
//
//  Created by Andrew Smith on 9/29/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "NSURLSessionTask+Courier.h"

@implementation NSURLSessionTask (Courier)

- (NSString *)taskIdentifierKey
{
    return [NSString stringWithFormat:@"%i", self.taskIdentifier];
}

@end
