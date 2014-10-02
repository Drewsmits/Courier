//
//  CRAsyncTestHelpers.m
//  Courier
//
//  Created by Andrew Smith on 10/2/14.
//  Copyright (c) 2014 Andrew B. Smith. All rights reserved.
//

#import "CRAsyncTestHelpers.h"

@implementation CRAsyncTestHelpers

void runInMainLoopUntilDone(void(^block)(BOOL *done)) {
    __block BOOL done = NO;
    block(&done);
    while (!done) {
        [[NSRunLoop mainRunLoop] runUntilDate:
         [NSDate dateWithTimeIntervalSinceNow:.1]];
    }
}

@end
