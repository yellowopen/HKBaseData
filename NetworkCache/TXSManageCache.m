//
//  TXSNetworkCache.m
//  TXSLiCai
//
//  Created by Mac on 2017/10/26.
//  Copyright © 2017年 Arvin. All rights reserved.
//
#import "TXSManageCache.h"
static NSString *const TXSContentResponseCache = @"TXSConentResponseCache";

static TXSManageCache *_netWorkCache;

@interface TXSManageCache()
@property (nonatomic, strong) TXSDiskCache *dataCache;
@end

@implementation TXSManageCache

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)initWithCachePathType:(TXSCacheManageType)cachePathType {
    NSString *path = [NSString stringWithFormat:@"%@%zd",TXSContentResponseCache,cachePathType];
    TXSManageCache *networkCache = [TXSManageCache sharedInstance];
    networkCache.dataCache = [TXSDiskCache initWithName:path cachePathType:cachePathType];
//    NSLog(@"%@", networkCache.dataCache.path);
    return networkCache;
}


+ (void)setContentCache:(id)contentData URL:(NSString *)URL parameters:(id)parameters {
    [self setContentCache:contentData URL:URL parameters:parameters cachePathType:TXSCacheManageTypeSQL | TXSCacheManageTypeFile];
}

+ (void)setContentCache:(id)contentData URL:(NSString *)URL parameters:(id)parameters cachePathType:(TXSCacheManageType)cachePathType{
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    // 异步缓存，不会阻塞主线程
    TXSManageCache *networkCache = [TXSManageCache initWithCachePathType:cachePathType];

    [networkCache.dataCache setObject:contentData forKey:cacheKey withBlock:nil];
}

+ (id)contentCacheForURL:(NSString *)URL parameters:(id)parameters {
   return [self contentCacheForURL:URL parameters:parameters cachePathType:TXSCacheManageTypeSQL | TXSCacheManageTypeFile];
}

+ (id)contentCacheForURL:(NSString *)URL parameters:(id)parameters cachePathType:(TXSCacheManageType)cachePathType{
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    TXSManageCache *networkCache = [TXSManageCache initWithCachePathType:cachePathType];
    return [networkCache.dataCache objectForKey:cacheKey];
}

+ (void)contentCacheForURL:(NSString *)URL parameters:(id)parameters cachePathType:(TXSCacheManageType)cachePathType successBlock:(void(^)(NSString *key, id<NSCoding> object))block {
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    TXSManageCache *networkCache = [TXSManageCache initWithCachePathType:cachePathType];
     [networkCache.dataCache objectForKey:cacheKey withBlock:block];
}

+ (NSInteger)getAllContentCacheSize {
    
    // 获取沙河路径
    NSInteger size = 0;
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *typeArray = @[@(TXSCacheManageTypeSQL),@(TXSCacheManageTypeFile),@(TXSCacheManageTypeCoData),@(TXSCacheManageTypeFMDB),@(TXSCacheManageTypeFile|TXSCacheManageTypeSQL)];
    NSFileManager *manage = [NSFileManager defaultManager];
    for (id type in typeArray) {// 删除文件
        NSString *path = [NSString stringWithFormat:@"%@%@",TXSContentResponseCache,type];
        NSString *cachePath = [cacheFolder stringByAppendingPathComponent:path];
        if ([manage isExecutableFileAtPath:cachePath]) {
            size += [[manage attributesOfItemAtPath:cachePath error:nil] fileSize];
        }
    }
    return size;
}

+ (NSInteger)getAllContentCacheSizeCachePathType:(TXSCacheManageType)cachePathType {
    TXSManageCache *networkCache = [self initWithCachePathType:cachePathType];
    return [networkCache.dataCache totalCost];
}

+(void)removeAllContentCache {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 获取沙河路径
        NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSArray *typeArray = @[@(TXSCacheManageTypeSQL),@(TXSCacheManageTypeFile),@(TXSCacheManageTypeCoData),@(TXSCacheManageTypeFMDB),@(TXSCacheManageTypeFile|TXSCacheManageTypeSQL)];
        NSFileManager *manage = [NSFileManager defaultManager];
        for (id type in typeArray) {// 删除文件
            NSString *path = [NSString stringWithFormat:@"%@%@",TXSContentResponseCache,type];
            NSString *cachePath = [cacheFolder stringByAppendingPathComponent:path];
            if ([manage isExecutableFileAtPath:cachePath]) {
                [manage removeItemAtPath:cachePath error:nil];
            }
        }
    });
}

+(void)removeAllContentCacheCachePathType:(TXSCacheManageType)cachePathType {
    TXSManageCache *networkCache = [self initWithCachePathType:cachePathType];
    [networkCache.dataCache removeAllObjects];
}

+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if(!parameters || parameters.count == 0){return URL;};
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",URL,paraString];
    
    return [NSString stringWithFormat:@"%zd",cacheKey.hash];
}

@end

