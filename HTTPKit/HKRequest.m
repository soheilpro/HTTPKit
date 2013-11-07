//
//  HKRequest.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 5/23/12.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

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
    HKRequestBase* baseRequest = [self baseRequest];

    [baseRequest send:^(HKResponseBase* response, NSError* error)
    {
        if (error != nil)
        {
            callback(nil, error);
            return;
        }

        HKResponse* apiResponse = [[HKResponse alloc] init];
        apiResponse.statusCode = response.statusCode;
        apiResponse.contentType = [HKRequest contentTypeFromHeader:[response.headers objectForKey:@"Content-Type"]];
        apiResponse.body = response.body;
        apiResponse.data = [HKRequest responseDataFromBody:apiResponse.body contentType:apiResponse.contentType];

        callback(apiResponse, nil);
    }];
}

- (HKRequestBase*)baseRequest
{
    NSString* url = [HKRequest urlWithBase:self.baseUrl path:self.path pathParams:self.pathParams queryParams:self.queryParams];
    NSData* requestContent = self.body ? : [HKRequest requestBodyFromData:self.data contentType:self.contentType];

    HKRequestBase* httpRequest = [[HKRequestBase alloc] init];
    httpRequest.method = self.method;
    httpRequest.url = url;
    [httpRequest.headers addEntriesFromDictionary:self.headers];
    httpRequest.cachePolicy = self.cachePolicy;

    if (requestContent != nil)
    {
        [httpRequest.headers setValue:self.contentType forKey:@"Content-Type"];
        httpRequest.body = requestContent;
    }

    return httpRequest;
}

#pragma mark - Class methods

+ (NSString*)urlWithBase:(NSString*)baseURL path:(NSString*)path pathParams:(NSArray*)pathParams queryParams:(NSDictionary*)queryParams
{
    NSString* rewrittenPath = [HKRequest rewrittenPath:path withParams:pathParams];
    NSString* queryString = [HKRequest queryStringWithParams:queryParams];
    NSString* url = [NSString stringWithFormat:@"%@/%@", baseURL, rewrittenPath];

    if (queryString.length > 0)
        url = [url stringByAppendingFormat:@"?%@", queryString];

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

+ (NSData*)requestBodyFromData:(NSDictionary*)data contentType:(NSString*)contentType
{
    if (data.count == 0)
        return nil;

    if ([contentType caseInsensitiveCompare:@"application/json"] == NSOrderedSame)
    {
        NSError* error = nil;
        NSData* rawRequestData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];

        if (error != nil)
            @throw error;
        
        return rawRequestData;
    }

    if ([contentType caseInsensitiveCompare:@"application/x-www-form-urlencoded"] == NSOrderedSame)
    {
        NSString* queryString = [self queryStringWithParams:data];
        
        return [queryString dataUsingEncoding:NSASCIIStringEncoding];
    }
    
    return nil;
}

+ (NSDictionary*)responseDataFromBody:(NSData*)content contentType:(NSString*)contentType
{
    if (contentType == nil)
        return nil;

    if ([contentType caseInsensitiveCompare:@"application/json"] == NSOrderedSame ||
        [contentType caseInsensitiveCompare:@"text/javascript"] == NSOrderedSame)
    {
        NSError* error = nil;
        NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:content options:0 error:&error];

        if (error != nil)
            @throw error;

        return responseData;
    }

    return nil;
}

@end
