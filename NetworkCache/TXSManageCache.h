//
//  TXSNetworkCache.h
//  TXSLiCai
//
//  Created by Mac on 2017/10/26.
//  Copyright © 2017年 Arvin. All rights reserved.
//
@class TXSDiskCache;
#import <Foundation/Foundation.h>
#import "TXSDiskCache.h"
#pragma mark - 网络数据缓存类
@interface TXSManageCache : NSObject
/** （增 删 改）
 *  异步缓存网络数据,根据请求的 URL与parameters
 *  做KEY存储数据, 这样就能缓存多级页面的数据
 *
 *  @param contentData   服务器返回的数据(新数据会覆盖老数据 nil时是删除)
 *  @param URL        请求的URL地址
 *  @param parameters 请求的参数
 */
+ (void)setContentCache:(id)contentData URL:(NSString *)URL parameters:(id)parameters;
/**< cachePathType:缓存方式 */
+ (void)setContentCache:(id)contentData URL:(NSString *)URL parameters:(id)parameters cachePathType:(TXSCacheManageType)cachePathType;

/**（查）
 *  根据请求的 URL与parameters 同步取出缓存数据
 *
 *  @param URL        请求的URL
 *  @param parameters 请求的参数
 *
 *  @return 缓存的服务器数据
 */
+ (id)contentCacheForURL:(NSString *)URL parameters:(id)parameters;
/**< cachePathType:缓存方式 */
+ (id)contentCacheForURL:(NSString *)URL parameters:(id)parameters cachePathType:(TXSCacheManageType)cachePathType;

/**
 异步获取数据

 @param URL 地址
 @param parameters 地址参数
 @param cachePathType 缓存类型
 @param block 成功
 */
+ (void)contentCacheForURL:(NSString *)URL parameters:(id)parameters cachePathType:(TXSCacheManageType)cachePathType successBlock:(void(^)(NSString *key, id<NSCoding> object))block ;

/// 获取缓存的总大小 bytes(字节)
+ (NSInteger)getAllContentCacheSize;
/**< cachePathType:缓存方式 */
+ (NSInteger)getAllContentCacheSizeCachePathType:(TXSCacheManageType)cachePathType ;

/// 删除所有缓存
+ (void)removeAllContentCache;
/**< cachePathType:缓存方式 */
+(void)removeAllContentCacheCachePathType:(TXSCacheManageType)cachePathType ;

@end
