//
//  CRResponse.m
//  Courier
//
//  Created by Andrew Smith on 10/19/11.
//  Copyright (c) 2011 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
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
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
//

#import "CRResponse.h"

@implementation CRResponse

+ (id)responseWithResponse:(NSURLResponse *)response 
               andCapacity:(NSInteger)capacity
{
    CRResponse *rep = [[self alloc] init];
    
    rep.response = response;
    rep.dataCapacity = capacity;
    rep.data = [[NSMutableData alloc] initWithCapacity:capacity];
    
    return rep;
}

- (NSInteger)statusCode
{
    return [(NSHTTPURLResponse *)self.response statusCode];
}

- (NSString *)statusCodeDescription
{
    return [NSHTTPURLResponse localizedStringForStatusCode:[self statusCode]];
}

- (BOOL)success
{
    if (self.statusCode > 100 && self.statusCode <= 302) {
        return YES;
    }
    return NO;
}

#pragma mark - Accessors

- (NSString *)responseDescription
{
    return [NSString stringWithUTF8String:[self.data bytes]];;
}

- (id)json
{
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:self.data
                                              options:NSJSONReadingMutableContainers
                                                error:&error];
    
    if (!json) {
        WLog(@"Unable to create JSON object response data. ERROR: %@", error);
        return nil;
    }

    return json;
}

- (BOOL)isDataJSON
{
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:self.data
                                              options:NSJSONReadingMutableContainers
                                                error:&error];
    
    if (!json) {
        return NO;
    }
    
    return YES;
}

@end
