//
//  TXSGetCache.m
//  TXSYYCacheManager
//
//  Created by Mac on 2018/1/23.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "TXSGetCache.h"
#import "TXSCache.h"
#import "TXSSQLCache.h"
#import "TXSFileCache.h"
#import "TXSCoreDataCache.h"

@implementation TXSGetCache
+ (TXSCache *)getCachePathWithPath:(NSString *)path Type:(TXSCacheManageType)type{
    switch (type) {
        case TXSCacheManageTypeSQL:
        {
            return [[TXSSQLCache alloc] initWithPath:path];
        }
            break;
        case TXSCacheManageTypeFile:
        {
            return [[TXSFileCache alloc] initWithPath:path];
        }
            break;
        case TXSCacheManageTypeFMDB:
        {
            return nil;
        }
            break;
        case (TXSCacheManageTypeSQL | TXSCacheManageTypeFile):// 要执行大于限制写入文件
        {
            TXSSQLCache *cache =  [[TXSSQLCache alloc] initWithPath:path];
            cache.fileCache = [[TXSFileCache alloc] initWithPath:path];
            return cache;
        }
            break;
        case TXSCacheManageTypeCoData:
        {
            return [[TXSCoreDataCache alloc]initWithPath:path];
        }
            break;
            
        default:
            NSLog(@"传入类型错误，只支持SQL 和 File 一起使用");
            return nil;
            break;
    }
}


@end
