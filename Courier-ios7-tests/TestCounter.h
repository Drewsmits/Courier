//
//  TestCounter.h
//  Broker
//
//  Created by Andrew Smith on 11/7/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestCounter : NSObject

- (void)add;

- (void)subtract;

- (void)waitUntil:(NSUInteger)number
          timeout:(NSUInteger)timeout;

@end
