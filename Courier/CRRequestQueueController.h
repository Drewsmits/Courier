//
//  CRRequestOperationController.h
//  Courier
//
//  Created by Andrew Smith on 7/26/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRRequestQueueController : CDQueueController

@property (nonatomic, strong, readonly) NSMutableDictionary *defaultHeader;

/**
 * This causes the reachability object to retain itself. This is by design in
 * the reachability framework. Calling stopNotifier will undo this.
 *
 * This also will post an NSNotification called kReachabilityChangedNotification
 * on the main thread. Observ
 */
- (void)startReachabilityNotifier;

/**
 * Stop monitoring reachability status and disable the notificaiton.
 */
- (void)stopReachabilityNotifier;

@end