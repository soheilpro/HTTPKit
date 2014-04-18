//
//  HKContentConverter.h
//  HTTPKit
//
//  Created by Soheil Rashidi on 4/18/14.
//  Copyright (c) 2014 Soheil Rashidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HKContentConverter <NSObject>

- (BOOL)supportsContentType:(NSString*)contentType;
- (NSData*)dataFromContent:(id)content contentType:(NSString**)contentType;
- (id)contentFromData:(NSData*)data contentType:(NSString*)contentType;

@end
