//
//  CourierTests.m
//  CourierTests
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import "CourierTests.h"

#import "Courier.h"

#import "CRRequestOperation.h"

@implementation CourierTests

- (void)setUp {
    [super setUp];

}

- (void)tearDown{
    [super tearDown];
}

#pragma mark - CRRequest

- (void)testCreateRequest {

    NSString *path = @"path/to/some/resource";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"one", @"two", @"three", nil]
                                                       forKeys:[NSArray arrayWithObjects:@"A"  , @"B"  , @"C"    , nil]];
    
    CRRequest *request = [CRRequest requestWithMethod:CRRequestMethodGET
                                              forPath:path
                                       withParameters:params
                                            andHeader:nil];

    STAssertNotNil(request, @"Should create request");
    STAssertEquals(request.method, CRRequestMethodGET, @"Should have correct method");
    STAssertEqualObjects(request.path, path, @"Should have correct path");
    STAssertEqualObjects(request.parameters, params, @"Should have correct params");
}

- (void)testRequestURL {

    NSString *path = @"path/to/some/resource";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"one", @"two", @"three", nil]
                                                       forKeys:[NSArray arrayWithObjects:@"A"  , @"B"  , @"C"    , nil]];

    CRRequest *request = [CRRequest requestWithMethod:CRRequestMethodGET
                                              forPath:path
                                       withParameters:params
                                            andHeader:nil];
    
    NSString *expectedPath = [NSString stringWithFormat:@"%@?A=one&B=two&C=three", path];
    NSURL *expectedURL = [NSURL URLWithString:expectedPath];
    
    STAssertEqualObjects(request.requestURL, expectedURL, @"Should have correct request URL");
}

#pragma mark - CRRequestOperation

- (void)testRequestOperation {
    
    NSString *path = @"http://posterous.com/api/2/users/me";
    
    [[Courier sharedInstance] setBasicAuthUsername:@"drewsmits@gmail.com" andPassword:@"dogscreenredchair"];
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
        
        NSLog(@"response: %@", [response statusCodeDescription]);
        
        if ([response statusCode] < 300) {
            success = YES;
        }
        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error){        
        hasCalledBack = YES;

        NSLog(@"FAILED! %@", error);
    }; 
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"dvuylfkoEfcoiyCBJrndueAnggEolmEz" forKey:@"api_token"];
    
    [[Courier sharedInstance] getPath:path
                           parameters:params
                              success:successBlock 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }

    STAssertTrue(success, @"Should properly connect");
}

@end
