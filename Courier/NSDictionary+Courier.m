//
//  NSDictionary+Courier.m
//  Courier
//
//  Created by Andrew Smith on 2/28/13.
//  Copyright (c) 2013 Andrew B. Smith. All rights reserved.
//

#import "NSDictionary+Courier.h"
#import "NSString+Courier.h"

@implementation NSDictionary (Courier)

#pragma mark - application/json

- (NSString *)asJSONString
{
    NSData *jsonData = [self asJSONData];
    if (!jsonData) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];    
}

- (NSData *)asJSONData
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) NSLog(@"JSON serialization error: %@", error);
    
    return jsonData;
}

#pragma mark - application/x-www-form-urlencoded

- (NSString *)asFormURLEncodedString
{
    __block NSMutableArray *mutableParameterComponents = [NSMutableArray array];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *encodedKey   = [[key description] urlEncodedStringWithEncoding:NSUTF8StringEncoding];
        NSString *encodedValue = [[obj description] urlEncodedStringWithEncoding:NSUTF8StringEncoding];
        NSString *component    = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        [mutableParameterComponents addObject:component];
    }];
    
    NSString *andJoinedString = [mutableParameterComponents componentsJoinedByString:@"&"];

    return andJoinedString;
}

- (NSData *)asFormURLEncodedData
{
    NSString *andJoinedString = [self asFormURLEncodedString];
    return [andJoinedString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
