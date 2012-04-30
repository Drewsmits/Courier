//
//  Courier+OAuth.m
//  Courier
//
//  Created by Andrew Smith on 4/8/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "Courier+OAuth.h"
#import "NSString+Courier.h"

static NSString *timestamp() {
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
    return [NSString stringWithFormat:@"%d", abs(interval)];
}

static NSString *nonce() {
	return [NSString stringWithFormat:@"%d%d", timestamp(), random()];
}

@implementation Courier (OAuth)

- (void)setOAuthConsumerKey:(NSString *)consumerKey 
                  andSecret:(NSString *)secret {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey,  @"oauth_consumer_key",
                            nonce(),      @"oauth_nonce",
                            timestamp(),  @"oauth_timestamp",
                            @"1.0",       @"oauth_version",
                            @"HMAC-SHA1", @"oauth_signature_method",
                            nil];
    
    NSMutableArray *paramsArray = [[NSMutableArray alloc] init];
    for (NSString *key in params.allKeys) {
        [paramsArray addObject:[NSString stringWithFormat:@"%@=\"%@\"", key, [params objectForKey:key]]];
    }
    
    NSString *p = [NSString stringWithFormat:@"Oath oauth_consumer_key=\"%@\"",consumerKey];
   
    [self.defaultHeader setValue:[p urlEncodedStringWithEncoding:NSUTF8StringEncoding]
                          forKey:@"Authorization"];
    
//  [self.defaultHeader setValue:[NSString stringWithFormat:@"%@", [paramsArray componentsJoinedByString:@", "]]
//                        forKey:@"Authorization"];
}

//- (NSString *)OAuthParametersString {
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            nil,          @"oauth_consumer_key",
//                            nonce(),      @"oauth_nonce",
//                            timestamp(),  @"oauth_timestamp",
//                            @"1.0",       @"oauth_version",
//                            @"HMAC-SHA1", @"oauth_signature_method",
//                            nil];
//    
//    NSMutableString *paramsString = [[NSMutableString alloc] init];
//    for (NSString *key in params.allKeys) {
//        [paramsString appendFormat:[NSString stringWithFormat:@"%@=\"%@\",", key, [params objectForKey:key]]];
//    }
//
//    
//    return paramsString;
//}

@end
