//
//  CRAsyncTestHelpers.h
//  Courier
//
//  Created by Andrew Smith on 10/2/14.
//  Copyright (c) 2014 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRAsyncTestHelpers : NSObject

void runInMainLoopUntilDone(void(^block)(BOOL *done));

@end
