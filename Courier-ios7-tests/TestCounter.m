//
//  TestCounter.m
//  Broker
//
//  Created by Andrew Smith on 11/7/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "TestCounter.h"

@interface TestCounter ()

@property (nonatomic, assign) NSUInteger counter;

@end

@implementation TestCounter

- (id)init
{
    self = [super init];
    if (self) {
        _counter = 1;
    }
    return self;
}

- (void)add
{
    self.counter++;
}

- (void)subtract
{
    self.counter--;
}

- (void)waitUntil:(NSUInteger)number
          timeout:(NSUInteger)timeout
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:5];
    while (self.counter != number || self.counter < number) {
        if ([timeoutDate timeIntervalSinceNow] <= 0) {
            break;
        }
        NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }
}

@end
