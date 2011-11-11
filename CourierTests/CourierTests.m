//
//  CourierTests.m
//  CourierTests
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Andrew B. Smith. All rights reserved.
//

#import "CourierTests.h"

#import "Courier.h"
#import "CRRequest.h"

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
    
    NSData *data = [path dataUsingEncoding:NSASCIIStringEncoding];
    
    CRRequest *request = [CRRequest requestWithMethod:CRRequestMethodGET
                                              forPath:path
                                       withParameters:params
                                          andHTTPBody:data
                                            andHeader:nil];

    STAssertNotNil(request, @"Should create request");
    STAssertEquals(request.method, CRRequestMethodGET, @"Should have correct method");
    STAssertEqualObjects(request.path, path, @"Should have correct path");
    STAssertEqualObjects(request.parameters, params, @"Should have correct params");
    STAssertEqualObjects(request.httpBody, data, @"Request should have correct HTTP body");
        
    NSString *expectedPath = [NSString stringWithFormat:@"%@?A=one&B=two&C=three", path];
    NSURL *expectedURL = [NSURL URLWithString:expectedPath];
    
    STAssertEqualObjects(request.requestURL, expectedURL, @"Should have correct request URL");
}

#pragma mark - CRRequestOperation

- (void)testGetRequest {
        
    NSString *path = @"http://localhost:4567/gettest";

    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
                
        if ([response statusCode] == 200) {            
            success = YES;
        }
        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
        
    [[Courier sharedInstance] getPath:path
                           parameters:nil
                              success:successBlock 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }

    STAssertTrue(success, @"Response should be 200");
}

- (void)testGetRequestWithURLThatDoesntExist {
    
    NSString *path = @"http://localhost:4567/a-route-that-doesnt-exist";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL expectedResponse = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error){        
        hasCalledBack = YES;
        
        if ([response statusCode] == 404) {
            expectedResponse = YES;
        }
        
    }; 
    
    [[Courier sharedInstance] getPath:path
                           parameters:nil
                              success:successBlock 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(expectedResponse, @"Response should be 404");
}

- (void)testPutRequest {
    
    NSString *path = @"http://localhost:4567/puttest";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
        
        if ([response statusCode] == 200) {            
            success = YES;
        }
        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
    
    [[Courier sharedInstance] putPath:path
                           parameters:nil
                              success:successBlock 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Response should be 200");
}

- (void)testPostRequest {
    
    NSString *path = @"http://localhost:4567/posttest";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
        
        if ([response statusCode] == 200) {            
            success = YES;
        }
        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
    
    [[Courier sharedInstance] postPath:path
                            parameters:nil
                               success:successBlock 
                               failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Response should be 200");
}

- (void)testDeleteRequest {
    
    NSString *path = @"http://localhost:4567/deletetest";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
        success = YES;        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
    
    [[Courier sharedInstance] deletePath:path
                              parameters:nil
                                 success:successBlock 
                                 failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Response should be 200");
}

- (void)testGetRequestWithParameters {
    
    NSString *path = @"http://localhost:4567/parameter";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationSuccessBlock successBlock = ^(CRRequest *request, CRResponse *response){        
        hasCalledBack = YES;
        success = YES;        
    };
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error){        
        hasCalledBack = YES;
        NSLog(@"FAILED! %@", error);
    }; 
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"myValue" forKey:@"myKey"];
    
    [[Courier sharedInstance] getPath:path
                           parameters:params
                              success:successBlock 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Should properly send parameters");
}

- (void)testGetRequestWithWrongParameters {
    
    NSString *path = @"http://localhost:4567/parameter";
    
    __block BOOL hasCalledBack = NO;
    __block BOOL success = NO;
    
    CRRequestOperationFailureBlock failBlock = ^(CRRequest *request, CRResponse *response, NSError *error){        
        hasCalledBack = YES;
        
        if ([response statusCode] == 500) {            
            success = YES;
        }
    }; 
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"blarg" forKey:@"gigigts"];
    
    [[Courier sharedInstance] getPath:path
                           parameters:params
                              success:nil 
                              failure:failBlock];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while (hasCalledBack == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue(success, @"Response should be 500");
}

@end
