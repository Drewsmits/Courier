//
//  CRURLProtocol.h
//  Courier
//
//  Created by Andrew Smith on 6/5/14.
//  Copyright (c) 2014 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRURLProtocol : NSURLProtocol

+ (void)resetGlobalSettings;

+ (void)setGlobalResponseDelay:(CGFloat)delay;

+ (void)setGlobalResponseStatusCode:(NSInteger)code;

+ (void)setGlobalResponseJson:(id)json;

+ (void)setGlobalResponseData:(NSData *)data;

+ (void)setGlobalCacheStoragePolicy:(NSURLCacheStoragePolicy)policy;

@end
