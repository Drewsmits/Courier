//
//  NSString+Courier.h
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Posterous. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Courier)

- (NSString *)urlEncodedString;
- (NSString *)urlEncodedStringWithEncoding:(NSStringEncoding)encoding;

@end
