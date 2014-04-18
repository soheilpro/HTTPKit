//
//  HKRequest.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 5/23/12.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

#import "HKFormData.h"
#import "HKFormDataContentConverter.h"
#import "HKFormURLEncodedContentConverter.h"
#import "HKHTTP.h"
#import "HKJSONContentConverter.h"
#import "HKRequest.h"
#import "HKXMLContentConverter.h"

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
        self.content = [NSMutableDictionary dictionary];
        self.contentConverters = [NSMutableArray array];
        [self.contentConverters addObject:[[HKJSONContentConverter alloc] init]];
        [self.contentConverters addObject:[[HKXMLContentConverter alloc] init]];
        [self.contentConverters addObject:[[HKFormURLEncodedContentConverter alloc] init]];
        [self.contentConverters addObject:[[HKFormDataContentConverter alloc] init]];
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
        response.headers = rawResponse.headers;
        response.contentType = [HKRequest contentTypeFromHeader:[rawResponse.headers objectForKey:@"Content-Type"]];
        response.body = rawResponse.body;
        response.content = [self contentFromData:response.body contentType:response.contentType];

        callback(response, nil);
    }];
}

- (HKRawRequest*)baseRequest
{
    NSString* url = [HKRequest urlWithProtocol:self.protocol baseURL:self.baseURL subdomain:self.subdomain path:self.path pathParams:self.pathParams queryParams:self.queryParams];

    NSString* contentType = self.contentType;
    NSData* body = self.body ? : [self dataFromContent:self.content contentType:&contentType];

    HKRawRequest* httpRequest = [[HKRawRequest alloc] init];
    httpRequest.method = self.method;
    httpRequest.url = url;
    [httpRequest.headers addEntriesFromDictionary:self.headers];
    httpRequest.cachePolicy = self.cachePolicy;

    if (body != nil)
    {
        [httpRequest.headers setValue:contentType forKey:@"Content-Type"];
        httpRequest.body = body;
    }

    return httpRequest;
}

#pragma mark - Class methods

+ (NSString*)urlWithProtocol:(NSString*)protocol baseURL:(NSString*)baseURL subdomain:(NSString*)subdomain path:(NSString*)path pathParams:(NSArray*)pathParams queryParams:(NSDictionary*)queryParams
{
    NSString* rewrittenPath = [HKRequest rewrittenPath:path withParams:pathParams];
    NSString* queryString = [HKHTTP queryStringWithParams:queryParams];
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
        [escapedParams addObject:[HKHTTP urlEncodedString:[NSString stringWithFormat:@"%@", param]]];

    NSRange range = NSMakeRange(0, [escapedParams count]);
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(id) * [escapedParams count]];
    [escapedParams getObjects:(__unsafe_unretained id*)data.mutableBytes range:range];

    return [[NSString alloc] initWithFormat:path arguments:data.mutableBytes];
}

+ (NSString*)contentTypeFromHeader:(NSString*)contentType
{
    NSRange range = [contentType rangeOfString:@";"];

    if (range.location == NSNotFound)
        return contentType;

    return [[contentType substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSData*)dataFromContent:(id)content contentType:(NSString**)contentType
{
    if (content == nil)
        return nil;

    if ([content isKindOfClass:[NSDictionary class]] && ((NSDictionary*)content).count == 0)
        return nil;

    if ([content isKindOfClass:[NSArray class]] && ((NSArray*)content).count == 0)
        return nil;

    for (id<HKContentConverter> contentConverter in self.contentConverters)
        if ([contentConverter supportsContentType:*contentType])
            return [contentConverter dataFromContent:content contentType:contentType];

    return nil;
}

- (id)contentFromData:(NSData*)data contentType:(NSString*)contentType
{
    if (contentType == nil)
        return nil;

    for (id<HKContentConverter> contentConverter in self.contentConverters)
        if ([contentConverter supportsContentType:contentType])
            return [contentConverter contentFromData:data contentType:contentType];

    return nil;
}

@end
