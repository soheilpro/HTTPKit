//
//  HKResponseBase.h
//  HTTPKit
//
//  Created by Soheil Rashidi on 6/16/12.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKResponseBase : NSObject

@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong) NSDictionary* headers;
@property (nonatomic, strong) NSData* body;

@end
