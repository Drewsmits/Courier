//
//  Courier+OAuth.h
//  Courier
//
//  Created by Andrew Smith on 4/8/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "Courier.h"

@interface Courier (OAuth)

/**

 */
- (void)setOAuthConsumerKey:(NSString *)consumerKey 
                  andSecret:(NSString *)secret;

//- (NSDictionary *)OAuthParameters;

@end
