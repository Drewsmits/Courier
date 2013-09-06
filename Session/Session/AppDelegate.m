//
//  AppDelegate.m
//  Session
//
//  Created by Andrew Smith on 8/31/13.
//  Copyright (c) 2013 andrewbsmith. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) SMStoreController *storeController;

@end

@implementation AppDelegate

+ (AppDelegate *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[UIApplication sharedApplication] delegate];
    });
    return _sharedObject;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

#pragma mark - StoreMad

- (SMStoreController *)storeController
{
    if (_storeController) return _storeController;
    _storeController = [self newStoreController];
    return _storeController;
}

- (SMStoreController *)newStoreController
{
    // sqlite
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocDirectory URLByAppendingPathComponent:@"SessionModel.sqlite"];
    
    // momd
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"SessionModel" withExtension:@"momd"];
    
    // controller
    SMStoreController *newStoreController = [SMStoreController storeControllerWithStoreURL:storeURL
                                                                               andModelURL:modelURL];
    
    //
    // Context saves when app changes state
    //
    [newStoreController shouldSaveOnAppStateChanges:YES];
    
    return newStoreController;
}

@end
