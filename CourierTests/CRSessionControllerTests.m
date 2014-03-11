//
//  CRSessionControllerTests.m
//  Courier
//
//  Created by Andrew Smith on 1/13/14.
//  Copyright (c) 2014 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//

#import "CRTestCase.h"

#import "CRSessionController.h"

#define kTestGroupName @"kBurritoCrew"
#define kTestGroup2Name @"kTacoCrew"

#define kTestTaskToken @"aToken"
#define kTestTask2Token @"bToken"

@interface CRSessionController (UnitTests)

@property (nonatomic, readonly) NSMutableDictionary *groups;

@property (nonatomic, readonly) NSMutableDictionary *tasks;

- (void)addTask:(NSURLSessionTask *)task
      withToken:(NSString *)token
        toGroup:(NSString *)group;

- (void)removeTask:(NSURLSessionTask *)task
         fromGroup:(NSString *)group;

@end

@interface CRSessionControllerTests : CRTestCase

@property (nonatomic, strong) CRSessionController *sessionController;

@end

@implementation CRSessionControllerTests

- (void)setUp
{
    [super setUp];
    _sessionController = [CRSessionController sessionControllerWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                                        delegate:nil];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (NSURLSessionTask *)googleTask
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    NSURLSessionTask *task = [_sessionController dataTaskForRequest:request completionHandler:nil];
    return task;
}

#pragma mark - Config

- (void)testSessionConfig
{
    XCTAssertNotNil(_sessionController.configuration,
                    @"Should have a non nil configuration");
}

#pragma mark -

- (void)testDataTaskForGroup
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];

    __block BOOL finished = NO;
    NSURLSessionDataTask *task = [_sessionController dataTaskForRequest:request
                                                              taskGroup:kTestGroupName
                                                      completionHandler:^(NSData *data,
                                                                          NSURLResponse *response,
                                                                          NSError *error) {
                                                          finished = YES;
                                                      }];
    
    // check group
    NSArray *tasks = [_sessionController.groups valueForKey:kTestGroupName];
    XCTAssertEqualObjects([tasks firstObject],
                          task,
                          @"Should be the same task");
    
    // Check tasks
    XCTAssertEqual(_sessionController.tasks.count,
                   1U,
                   @"Should have one task");
    
    id key = [[_sessionController.tasks allKeys] firstObject];
    NSDictionary *object = [_sessionController.tasks objectForKey:key];
    XCTAssertEqualObjects(object[@"group"],
                          kTestGroupName,
                          @"Should have correc group name");
    XCTAssertEqualObjects(object[@"task"],
                          task,
                          @"Should be the same task");
    
    [task resume];
    
    //
    // Wait until finished
    //
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
    while (finished == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }
    
    XCTAssertEqual(_sessionController.groups.count,
                   0U,
                   @"Should have no task groups after completion");
    
    XCTAssertEqual(_sessionController.tasks.count,
                   0U,
                   @"Should have no tasks after completion");

}

#pragma mark - Task Management

- (void)testAddTask
{
    NSArray *tasks = [_sessionController.groups valueForKey:kTestGroupName];
    XCTAssertNil(tasks, @"Should not have a task array for group");
    
    NSURLSessionTask *task = [NSURLSessionTask new];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:kTestGroupName];
    
    tasks = [_sessionController.groups valueForKey:kTestGroupName];
    
    XCTAssertNotNil(tasks, @"Should have a task array for group");
    XCTAssertEqual(tasks.count, 1U, @"Should have one task for group");
    XCTAssertEqualObjects([tasks firstObject], task, @"Should be the same task");
}

- (void)testAddNilTask
{
    NSURLSessionTask *task;
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:kTestGroupName];
    NSArray *tasks = [_sessionController.groups valueForKey:kTestGroupName];
    XCTAssertNil(tasks, @"Should not have a task array for group");
}

- (void)testAddTaskToNilGroup
{
    NSURLSessionTask *task = [NSURLSessionTask new];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:nil];
    
    XCTAssertEqual(_sessionController.groups.count,
                   1U,
                   @"Should have one task group");
    
    NSArray *tasks = [_sessionController.groups valueForKey:@"kCRSessionControllerGenericTaskGroup"];
   
    XCTAssertNotNil(tasks,
                    @"Should have a generic task group");
}

- (void)testAddTaskToEmptyStringGroup
{
    NSURLSessionTask *task = [NSURLSessionTask new];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:@""];
    
    XCTAssertEqual(_sessionController.groups.count,
                   1U,
                   @"Should have one task group");
    
    NSArray *tasks = [_sessionController.groups valueForKey:@"kCRSessionControllerGenericTaskGroup"];
    XCTAssertNotNil(tasks,
                    @"Should not have a task array for group");
}

- (void)testRemoveTask
{
    // Add task first
    NSURLSessionTask *task = [NSURLSessionTask new];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:kTestGroupName];
    
    // Remove task
    [_sessionController removeTask:task
                         fromGroup:kTestGroupName];
    
    XCTAssertEqual(_sessionController.groups.count,
                   0U,
                   @"Should not have task group for tasks when empty");
}

- (void)testRemoveTaskFromNilGroup
{
    NSURLSessionTask *task = [NSURLSessionTask new];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:nil];
    
    // Remove task
    [_sessionController removeTask:task
                         fromGroup:nil];
    
    XCTAssertEqual(_sessionController.groups.count,
                   0U,
                   @"Should not have task group for tasks when empty");
}

#pragma mark - State Management

- (void)testSuspendTasksInGroup
{
    // Add task first
    NSURLSessionTask *task = [self googleTask];
    [task resume];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:kTestGroupName];
    
    // Add task first
    NSURLSessionTask *task2 = [NSURLSessionTask new];
    [_sessionController addTask:task
                      withToken:kTestTask2Token
                        toGroup:kTestGroup2Name];
    
    [_sessionController suspendTasksInGroup:kTestGroupName];
    
    XCTAssertEqual(task.state,
                   NSURLSessionTaskStateSuspended,
                   @"Task should be suspended");
    
    XCTAssertEqual(task2.state,
                   NSURLSessionTaskStateRunning,
                   @"Task should be running");
}

- (void)testResumeTasksInGroup
{
    NSURLSessionTask *task = [self googleTask];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:kTestGroupName];
    
    XCTAssertEqual(task.state,
                   NSURLSessionTaskStateSuspended,
                   @"Task should be suspended");
    
    [_sessionController resumeTasksInGroup:kTestGroupName];
    
    XCTAssertEqual(task.state,
                   NSURLSessionTaskStateRunning,
                   @"Task should be running");
}

- (void)testCancelTasksInGroup
{
    NSURLSessionTask *task = [self googleTask];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:kTestGroupName];
    
    [_sessionController cancelTasksInGroup:kTestGroupName];
    
    XCTAssertEqual(task.state,
                   NSURLSessionTaskStateCanceling,
                   @"Task should be canceled");
}

- (void)testSuspendAllTasks
{
    NSURLSessionTask *task = [self googleTask];
    [task resume];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:kTestGroupName];
    
    // Add task first
    NSURLSessionTask *task2 = [self googleTask];
    [task2 resume];
    [_sessionController addTask:task2
                      withToken:kTestTask2Token
                        toGroup:kTestGroup2Name];

    [_sessionController suspendAllTasks];
    
    XCTAssertEqual(task.state,
                   NSURLSessionTaskStateSuspended,
                   @"Task should be suspended");
    
    
    XCTAssertEqual(task2.state,
                   NSURLSessionTaskStateSuspended,
                   @"Task should be suspended");
}

- (void)testResumeAllTasks
{
    NSURLSessionTask *task = [self googleTask];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:kTestGroupName];
    
    // Add task first
    NSURLSessionTask *task2 = [self googleTask];
    [_sessionController addTask:task2
                      withToken:kTestTask2Token
                        toGroup:kTestGroup2Name];
    
    [_sessionController resumeAllTasks];
    
    XCTAssertEqual(task.state,
                   NSURLSessionTaskStateRunning,
                   @"Task should be suspended");
    
    
    XCTAssertEqual(task2.state,
                   NSURLSessionTaskStateRunning,
                   @"Task should be suspended");
}

- (void)testCancelAllTasks
{
    NSURLSessionTask *task = [self googleTask];
    [_sessionController addTask:task
                      withToken:kTestTaskToken
                        toGroup:kTestGroupName];
    
    // Add task first
    NSURLSessionTask *task2 = [self googleTask];
    [_sessionController addTask:task2
                      withToken:kTestTask2Token
                        toGroup:kTestGroup2Name];

    [_sessionController cancelAllTasks];
    
    BOOL result = task.state == NSURLSessionTaskStateCanceling
                  || task.state == NSURLSessionTaskStateCompleted;
    
    XCTAssertTrue(result,
                  @"Task should be canceled or completed");
    
    result = task.state == NSURLSessionTaskStateCanceling
             || task.state == NSURLSessionTaskStateCompleted;
    
    XCTAssertTrue(result,
                  @"Task should be canceled or completed");
}

@end
