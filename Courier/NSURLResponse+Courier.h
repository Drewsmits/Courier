//
//  NSURLResponse+Courier.h
//  Courier
//
//  Created by Andrew Smith on 8/31/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLResponse (Courier)

@property (readonly) NSInteger statusCode;

- (BOOL)success;

@end
