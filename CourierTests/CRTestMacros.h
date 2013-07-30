//
//  CRTestMacros.h
//  Courier
//
//  Created by Andrew Smith on 7/29/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#ifndef Courier_CRTestMacros_h
#define Courier_CRTestMacros_h

#define TEST_QUEUE @"com.courier.testRequestQueue"

#define WAIT_ON_BOOL(value) NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];\
                            while (value == NO) {\
                              [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];\
                            }\

#endif
