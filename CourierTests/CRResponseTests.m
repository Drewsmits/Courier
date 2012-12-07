//
//  CRResponseTests.m
//  Courier
//
//  Created by Andrew Smith on 12/6/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "CRResponseTests.h"
#import "CRResponse.h"

@implementation CRResponseTests

- (void)testResponseSuccess
{
    CRResponse *response = [CRResponse new];
    
    for (int i = 0; i < 200; i++) {
        STAssertFalse([response isStatusCodeSuccess:i], @"Should be successfull");
    }
    
    for (int i = 200; i < 300; i++) {
        STAssertTrue([response isStatusCodeSuccess:i], @"Should be successfull");
    }
    
    for (int i = 300; i < 1000; i++) {
        STAssertFalse([response isStatusCodeSuccess:i], @"Should be successfull");
    }
}

@end
