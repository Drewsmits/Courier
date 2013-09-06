//
//  AppDelegate.h
//  Session
//
//  Created by Andrew Smith on 8/31/13.
//  Copyright (c) 2013 andrewbsmith. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <StoreMad/StoreMad.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, readonly) SMStoreController *storeController;

+ (AppDelegate *)sharedInstance;

@end
