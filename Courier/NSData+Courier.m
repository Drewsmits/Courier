//
//  NSData+Courier.m
//  Courier
//
//  Created by Andrew Smith on 10/20/11.
//  Copyright (c) 2011 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
//
//  Shamelessly borrowed from:
//  NSData+AFNetworking.h
//
//  Copyright (c) 2011 Gowalla (http://gowalla.com/)
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

#import "NSData+Courier.h"
#import <zlib.h>

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSData (Courier)

+ (id)dataWithBase64EncodedString:(NSString *)string
{
	if (string == nil)
		[NSException raise:NSInvalidArgumentException format:nil];
	if ([string length] == 0)
		return [NSData data];
    
	static char *decodingTable = NULL;
	if (decodingTable == NULL)
	{
		decodingTable = malloc(256);
		if (decodingTable == NULL)
			return nil;
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++)
			decodingTable[(short)encodingTable[i]] = i;
	}
    
	const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
	if (characters == NULL)     //  Not an ASCII string!
		return nil;
	char *bytes = malloc((([string length] + 3) / 4) * 3);
	if (bytes == NULL)
		return nil;
	NSUInteger length = 0;
    
	NSUInteger i = 0;
	while (YES)
	{
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++)
		{
			if (characters[i] == '\0')
				break;
			if (isspace(characters[i]) || characters[i] == '=')
				continue;
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
			{
				free(bytes);
				return nil;
			}
		}
        
		if (bufferLength == 0)
			break;
		if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
		{
			free(bytes);
			return nil;
		}
        
		//  Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2)
			bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
		if (bufferLength > 3)
			bytes[length++] = (buffer[2] << 6) | buffer[3];
	}
    
	realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64EncodedString
{
	if ([self length] == 0)
		return @"";
    
    char *characters = malloc((([self length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
    
	NSUInteger i = 0;
	while (i < [self length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [self length])
			buffer[bufferLength++] = ((char *)[self bytes])[i++];
        
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';	
	}
    
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

//
//static char Base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
//
//- (NSString *)base64EncodedString {
//    NSUInteger length = [self length];
//    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
//    
//    uint8_t *input = (uint8_t *)[self bytes];
//    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
//    
//    for (NSUInteger i = 0; i < length; i += 3) {
//        NSUInteger value = 0;
//        for (NSUInteger j = i; j < (i + 3); j++) {
//            value <<= 8;
//            
//            if (j < length) {
//                value |= (0xFF & input[j]); 
//            }
//        }
//        
//        NSInteger idx = (i / 3) * 4;
//        output[idx + 0] = Base64EncodingTable[(value >> 18) & 0x3F];
//        output[idx + 1] = Base64EncodingTable[(value >> 12) & 0x3F];
//        output[idx + 2] = (i + 1) < length ? Base64EncodingTable[(value >> 6)  & 0x3F] : '=';
//        output[idx + 3] = (i + 2) < length ? Base64EncodingTable[(value >> 0)  & 0x3F] : '=';
//    }
//    
//    return [[[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding] autorelease];
//}

- (NSData *)dataByGZipCompressingWithError:(NSError **)error {
    if ([self length] == 0) {
        return self;
    }
	
	z_stream zStream;
    
	zStream.zalloc = Z_NULL;
	zStream.zfree = Z_NULL;
	zStream.opaque = Z_NULL;
	zStream.next_in = (Bytef *)[self bytes];
	zStream.avail_in = [self length];
    zStream.total_out = 0;
    
	if (deflateInit(&zStream, Z_DEFAULT_COMPRESSION) != Z_OK) {
        return nil;
    }
    
    NSUInteger compressionChunkSize = 16384; // 16Kb
	NSMutableData *compressedData = [NSMutableData dataWithLength:compressionChunkSize];
    
	do {
        if (zStream.total_out >= [compressedData length]) {
			[compressedData increaseLengthBy:compressionChunkSize];
		}
        
		zStream.next_out = [compressedData mutableBytes] + zStream.total_out;
		zStream.avail_out = [compressedData length] - zStream.total_out;
		
		deflate(&zStream, Z_FINISH);  
		
	} while (zStream.avail_out == 0);
	
	deflateEnd(&zStream);
	[compressedData setLength:zStream.total_out];
    
	return [NSData dataWithData:compressedData];
}

- (NSData *)dataByGZipDecompressingDataWithError:(NSError **)error {
    z_stream zStream;
	
    zStream.zalloc = Z_NULL;
	zStream.zfree = Z_NULL;
	zStream.next_in = (Bytef *)[self bytes];
	zStream.avail_in = [self length];
	zStream.avail_out = 0;
    zStream.total_out = 0;
    
    NSUInteger estimatedLength = [self length] / 2;
	NSMutableData *decompressedData = [NSMutableData dataWithLength:estimatedLength];
    
    do {
        if (zStream.total_out >= [decompressedData length]) {
			[decompressedData increaseLengthBy:estimatedLength / 2];
		}
        
		zStream.next_out = [decompressedData mutableBytes] + zStream.total_out;
		zStream.avail_out = [decompressedData length] - zStream.total_out;
        
        int status = inflate(&zStream, Z_FINISH);
		
		if (status == Z_STREAM_END) {
			break;
		} else if (status != Z_OK) {
            if (error) {
                *error = [NSError errorWithDomain:nil code:status userInfo:nil];
            }
			return nil;
		}  
    } while (zStream.avail_out == 0);
    
	[decompressedData setLength:zStream.total_out];
    
	return [NSData dataWithData:decompressedData];
}


@end
