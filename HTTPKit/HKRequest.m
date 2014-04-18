//
//  HKRequest.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 5/23/12.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

#import "HKFormData.h"
#import "HKRequest.h"

@implementation HKRequest

#pragma mark - Init

- (id)init
{
    self = [super init];

    if (self)
    {
        self.pathParams = [NSMutableArray array];
        self.queryParams = [NSMutableDictionary dictionary];
        self.headers = [NSMutableDictionary dictionary];
        self.contentType = @"application/x-www-form-urlencoded";
        self.data = [NSMutableDictionary dictionary];
    }

    return self;
}

#pragma mark - Methods

- (void)send:(void (^)(HKResponse* response, NSError* error))callback;
{
    HKRawRequest* rawRequest = [self baseRequest];

    [rawRequest send:^(HKRawResponse* rawResponse, NSError* error)
    {
        if (error != nil)
        {
            callback(nil, error);
            return;
        }

        HKResponse* response = [[HKResponse alloc] init];
        response.statusCode = rawResponse.statusCode;
        response.contentType = [HKRequest contentTypeFromHeader:[rawResponse.headers objectForKey:@"Content-Type"]];
        response.body = rawResponse.body;
        response.data = [HKRequest responseDataFromBody:response.body contentType:response.contentType];

        callback(response, nil);
    }];
}

- (HKRawRequest*)baseRequest
{
    NSString* url = [HKRequest urlWithProtocol:self.protocol baseURL:self.baseURL subdomain:self.subdomain path:self.path pathParams:self.pathParams queryParams:self.queryParams];

    NSString* contentType = self.contentType;
    NSData* requestContent = self.body ? : [HKRequest requestBodyFromData:self.data contentType:&contentType];

    HKRawRequest* httpRequest = [[HKRawRequest alloc] init];
    httpRequest.method = self.method;
    httpRequest.url = url;
    [httpRequest.headers addEntriesFromDictionary:self.headers];
    httpRequest.cachePolicy = self.cachePolicy;

    if (requestContent != nil)
    {
        [httpRequest.headers setValue:contentType forKey:@"Content-Type"];
        httpRequest.body = requestContent;
    }

    return httpRequest;
}

#pragma mark - Class methods

+ (NSString*)urlWithProtocol:(NSString*)protocol baseURL:(NSString*)baseURL subdomain:(NSString*)subdomain path:(NSString*)path pathParams:(NSArray*)pathParams queryParams:(NSDictionary*)queryParams
{
    NSString* rewrittenPath = [HKRequest rewrittenPath:path withParams:pathParams];
    NSString* queryString = [HKRequest queryStringWithParams:queryParams];
    NSString* url = baseURL;

    if (subdomain.length > 0)
        url  = [NSString stringWithFormat:@"%@.%@", subdomain, url];

    if (rewrittenPath.length > 0)
        url  = [NSString stringWithFormat:@"%@/%@", url, rewrittenPath];

    if (queryString.length > 0)
        url = [NSString stringWithFormat:@"%@?%@", url, queryString];

    url = [NSString stringWithFormat:@"%@://%@", protocol, url];

    return url;
}

+ (NSString*)rewrittenPath:(NSString*)path withParams:(NSArray*)params
{
    if (params.count == 0)
        return path;

    NSMutableArray* escapedParams = [NSMutableArray arrayWithCapacity:params.count];

    for (NSString* param in params)
        [escapedParams addObject:[HKRequest urlEncodedString:[NSString stringWithFormat:@"%@", param]]];

    NSRange range = NSMakeRange(0, [escapedParams count]);
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(id) * [escapedParams count]];
    [escapedParams getObjects:(__unsafe_unretained id*)data.mutableBytes range:range];

    return [[NSString alloc] initWithFormat:path arguments:data.mutableBytes];
}

+ (NSString*)queryStringWithParams:(NSDictionary*)params
{
    if (params.count == 0)
        return @"";

    NSMutableArray* args = [NSMutableArray array];

    for (NSString* key in params)
    {
        NSString* value = [NSString stringWithFormat:@"%@", [params objectForKey:key]];
        NSString* encodedKey = [HKRequest urlEncodedString:key];
        NSString* encodedValue = [HKRequest urlEncodedString:value];
        NSString* arg = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];

        [args addObject:arg];
    }

    return [args componentsJoinedByString:@"&"];
}

+ (NSString*)urlEncodedString:(NSString*)string
{
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!;/?:@&=$+{}()<>,", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

+ (NSString*)contentTypeFromHeader:(NSString*)contentType
{
    NSRange range = [contentType rangeOfString:@";"];

    if (range.location == NSNotFound)
        return contentType;

    return [[contentType substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (NSData*)requestBodyFromData:(id)data contentType:(NSString**)contentType
{
    if ([data isKindOfClass:[NSDictionary class]] && ((NSDictionary*)data).count == 0)
        return nil;

    if ([data isKindOfClass:[NSArray class]] && ((NSArray*)data).count == 0)
        return nil;

    if ([*contentType caseInsensitiveCompare:@"application/json"] == NSOrderedSame)
    {
        NSError* error = nil;
        NSData* rawRequestData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];

        if (error != nil)
            @throw error;
        
        return rawRequestData;
    }

    if ([*contentType caseInsensitiveCompare:@"application/x-www-form-urlencoded"] == NSOrderedSame)
    {
        NSString* queryString = [self queryStringWithParams:data];
        
        return [queryString dataUsingEncoding:NSASCIIStringEncoding];
    }

    if ([*contentType caseInsensitiveCompare:@"multipart/form-data"] == NSOrderedSame)
    {
        NSMutableData* result = [NSMutableData data];
        NSString* boundry = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];

        [data enumerateObjectsUsingBlock:^(HKFormData* formData, NSUInteger idx, BOOL* stop)
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

    return nil;
}

+ (id)responseDataFromBody:(NSData*)content contentType:(NSString*)contentType
{
    if (contentType == nil)
        return nil;

    if ([contentType caseInsensitiveCompare:@"application/json"] == NSOrderedSame ||
        [contentType caseInsensitiveCompare:@"text/javascript"] == NSOrderedSame)
    {
        NSError* error = nil;
        id responseData = [NSJSONSerialization JSONObjectWithData:content options:0 error:&error];

        if (error != nil)
            @throw error;

        return responseData;
    }

    return nil;
}

@end
