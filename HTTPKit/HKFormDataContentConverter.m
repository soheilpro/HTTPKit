//
//  HKFormDataContentConverter.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 4/18/14.
//  Copyright (c) 2014 Soheil Rashidi. All rights reserved.
//

#import "HKFormData.h"
#import "HKFormDataContentConverter.h"

@implementation HKFormDataContentConverter

- (BOOL)supportsContentType:(NSString*)contentType
{
    if ([contentType caseInsensitiveCompare:@"multipart/form-data"] == NSOrderedSame)
        return YES;

    return NO;
}

- (NSData*)dataFromContent:(id)content contentType:(NSString**)contentType
{
    NSMutableData* result = [NSMutableData data];
    NSString* boundry = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];

    [content enumerateObjectsUsingBlock:^(HKFormData* formData, NSUInteger idx, BOOL* stop)
     {
         [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
         [result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", formData.name, formData.filename] dataUsingEncoding:NSUTF8StringEncoding]]; // TODO: Escape name and filename
         [result appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", formData.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
         [result appendData:formData.data];
         [result appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
     }];

    [result appendData:[[NSString stringWithFormat:@"--%@--", boundry] dataUsingEncoding:NSUTF8StringEncoding]];

    *contentType = [*contentType stringByAppendingFormat:@"; boundary=%@", boundry];

    return result;
}

- (id)contentFromData:(NSData*)data contentType:(NSString*)contentType
{
    return nil;
}

@end
