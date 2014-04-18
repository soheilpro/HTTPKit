//
//  HKRequest.h
//  HTTPKit
//
//  Created by Soheil Rashidi on 5/23/12.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

#import "HKRawRequest.h"
#import "HKResponse.h"
#import <Foundation/Foundation.h>

@class HKResponse;

@interface HKRequest : NSObject

@property (nonatomic, strong) NSString* method;
@property (nonatomic, strong) NSString* protocol;
@property (nonatomic, strong) NSString* subdomain;
@property (nonatomic, strong) NSString* baseURL;
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSMutableArray* pathParams;
@property (nonatomic, strong) NSMutableDictionary* queryParams;
@property (nonatomic, strong) NSMutableDictionary* headers;
@property (nonatomic, strong) NSString* contentType;
@property (nonatomic, strong) NSData* body;
@property (nonatomic, strong) id data;
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, strong, readonly) HKRawRequest* rawRequest;

- (void)send:(void (^) (HKResponse* response, NSError* error))callback;

@end
