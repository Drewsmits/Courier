//
//  NSData+Courier.h
//  Courier
//
//  Created by Andrew Smith on 10/20/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Courier)

- (NSString *)base64EncodedString;
- (NSData *)dataByGZipCompressingWithError:(NSError **)error;
- (NSData *)dataByGZipDecompressingDataWithError:(NSError **)error;

@end
