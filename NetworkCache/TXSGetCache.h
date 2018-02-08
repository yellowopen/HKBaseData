//
//  TXSGetCache.h
//  TXSYYCacheManager
//
//  Created by Mac on 2018/1/23.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TXSCache;

typedef NS_OPTIONS(NSUInteger, TXSCacheManageType) {
    TXSCacheManageTypeSQL   = 1 << 0,
    TXSCacheManageTypeFile  = 1 << 1,
    TXSCacheManageTypeFMDB  = 1 << 2,
    TXSCacheManageTypeCoData= 1 << 3,
};


@interface TXSGetCache : NSObject
+ (TXSCache *)getCachePathWithPath:(NSString *)path Type:(TXSCacheManageType)type;
@end
