//
//  CRTestCase.m
//  Courier
//
//  Created by Andrew Smith on 1/13/14.
//  Copyright (c) 2014 Andrew B. Smith. All rights reserved.
//

#import "CRTestCase.h"

extern void __gcov_flush(void);

@implementation CRTestCase

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
    __gcov_flush();
}

@end
