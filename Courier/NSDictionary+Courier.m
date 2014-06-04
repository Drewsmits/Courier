//
//  NSDictionary+Courier.m
//  Courier
//
//  Created by Andrew Smith on 2/28/13.
//  Copyright (c) 2013 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSDictionary+Courier.h"
#import "NSString+Courier.h"

@implementation NSDictionary (Courier)

#pragma mark - application/json

- (NSString *)cou_asJSONString
{
    NSData *jsonData = [self cou_asJSONData];
    if (!jsonData) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];    
}

- (NSData *)cou_asJSONData
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) NSLog(@"JSON serialization error: %@", error);
    
    return jsonData;
}

#pragma mark - application/x-www-form-urlencoded

- (NSString *)cou_asFormURLEncodedString
{
    __block NSMutableArray *mutableParameterComponents = [NSMutableArray array];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *encodedKey   = [[key description] cou_urlEncodedStringWithEncoding:NSUTF8StringEncoding];
        NSString *encodedValue = [[obj description] cou_urlEncodedStringWithEncoding:NSUTF8StringEncoding];
        NSString *component    = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        [mutableParameterComponents addObject:component];
    }];
    
    NSString *andJoinedString = [mutableParameterComponents componentsJoinedByString:@"&"];

    return andJoinedString;
}

- (NSData *)cou_asFormURLEncodedData
{
    NSString *andJoinedString = [self cou_asFormURLEncodedString];
    return [andJoinedString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
