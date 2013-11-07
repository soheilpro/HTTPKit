//
//  HKRequestBase.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 6/16/12.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

#import "HKRequestBase.h"

@interface HKRequestBase ()

@property (nonatomic, strong) void (^callback)(HKResponseBase* response, NSError* error);
@property (nonatomic, strong) HKResponseBase* response;

@end

@implementation HKRequestBase

#pragma mark - Init

- (id)init
{
    self = [super init];

    if (self)
    {
        self.headers = [NSMutableDictionary dictionary];
    }

    return self;
}

#pragma mark - Methods

- (void)send:(void (^)(HKResponseBase* response, NSError* error))callback;
{
    NSURLRequest* urlRequest = [self urlRequest];

    self.callback = callback;

    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [connection start];
}

- (void)invalidateCachedResponse
{
    NSURLRequest* urlRequest = [self urlRequest];

    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:urlRequest];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;

    self.response = [[HKResponseBase alloc] init];
    self.response.statusCode = httpResponse.statusCode;
    self.response.headers = httpResponse.allHeaderFields;
    self.response.body = [NSMutableData data];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [(NSMutableData*)self.response.body appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    self.callback(self.response, nil);
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    self.callback(nil, error);
}

#pragma mark -

- (NSURLRequest*)urlRequest
{
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] init];
    urlRequest.HTTPMethod = self.method;
    urlRequest.URL = [NSURL URLWithString:self.url];
    urlRequest.allHTTPHeaderFields = self.headers;
    urlRequest.cachePolicy = self.cachePolicy;

    if (self.body != nil)
    {
        [urlRequest setValue:[NSString stringWithFormat:@"%d", self.body.length] forHTTPHeaderField:@"Content-Length"];
        urlRequest.HTTPBody = self.body;
    }

    return urlRequest;
}

@end
