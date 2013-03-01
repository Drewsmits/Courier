//
//  NSDictionary+Courier.h
//  Courier
//
//  Created by Andrew Smith on 2/28/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Courier)

/**
 * NSUTF8StringEncoding encoded JSON string
 */
- (NSString *)asJSONString;

/**
 * NSJSONSerialization representation
 */
- (NSData *)asJSONData;

/**
 * & joined form URL encoded string as NSData
 */
- (NSData *)asFormURLEncodedData;

@end
