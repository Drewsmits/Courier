//
//  CRRequestController.h
//  Courier
//
//  Created by Andrew Smith on 6/13/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CRRequestOperation;
@class CRResponse;

@interface CRRequestController : NSObject

/**
 Default headers used for every request
 */
@property (nonatomic, strong) NSMutableDictionary *defaultHeader;

@end
