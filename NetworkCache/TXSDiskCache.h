//
//  TXSDiskCache.h
//  TXSCacheManager
//
//  Created by Mac on 2017/11/27.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXSGetCache.h"
NS_ASSUME_NONNULL_BEGIN
@interface TXSDiskCache : NSObject

/** 缓存名称*/
@property (nonatomic, strong) NSString *name;
/** 缓存路径*/
@property (nonatomic, strong,readonly) NSString *path;
/** 缓存大小限制 默认20480（20kb）*/
@property (readonly) NSUInteger inlineThreshold;

///**
// NSKeyedArchiver。使用这个块来支持不支持的对象 遵守“NSCoding”协议的归档
// 默认为空.
// */
@property (nullable, copy) NSData *(^customArchiveBlock)(id object);
/**
  unarchive  支持没有遵循 NSCoding.
 */
@property (nullable, copy) id (^customUnarchiveBlock)(NSData *data);

/**
 生成文件名字
 */
@property (nullable, copy) NSString *(^customFileNameBlock)(NSString *key);



#pragma mark - Limit
///=============================================================================
/// @name Limit
///=============================================================================

/**
 缓存的最大对象数
 */
@property NSUInteger countLimit;

/**
 回收对象后的缓存最大数
 */
@property NSUInteger costLimit;

/**
 对象最大过期时间
 */
@property NSTimeInterval ageLimit;

/**
 缓存应该保留的最小磁盘空间，小于这个将删除其他内容
 */
@property NSUInteger freeDiskSpaceLimit;

/**
 自动调整检查时间间隔以秒为单位。默认值是60(1分钟)。
 */
@property NSTimeInterval autoTrimInterval;

/**
 错误日志打印
 */
@property BOOL errorLogsEnabled;

#pragma mark - Initializer
// 这两个初始方法不能用
///=============================================================================
/// @name Initializer
///=============================================================================
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 根据路径初始化
 @param name 相对路径.
 @return 缓存对象.
 
 */
- (instancetype)initWithName:(NSString *)name cachePathType:(TXSCacheManageType)cachePathType;

+ (instancetype)initWithName:(NSString *)name cachePathType:(TXSCacheManageType)cachePathType;


#pragma mark - Access Methods

/**
 是否存在对应键的值 会阻塞线程
  @param  key 键值.
 @return 是否存在.
 */
- (BOOL)containsObjectForKey:(NSString *)key;

///以下block 返回是在子线程中，注意⚠️
/**
 是否存在对应键的值 会阻塞线程
 @param  key 键值.
 @param  block 结果值.
 */
- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block;

/**
 返回key 对应的值
 */
- (nullable id<NSCoding>)objectForKey:(NSString *)key;


/**
 返回key对应的值

 @param key key
 @param block 结果
 */
- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> _Nullable object))block;

/**
 写入值（会阻塞线程）
 
 @param object 对象
 @param key key
 */
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

/**
 写入值

 @param object 对象
 @param key key
 @param block 结果
 */
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key withBlock:(nullable void(^)(void))block;

/**
 删除对象
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 后台删除对象
 */
- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block;

/**
删除全部内容（阻塞线程）
 */
- (void)removeAllObjects;

/**
删除全部内容（不阻塞线程）
 */
- (void)removeAllObjectsWithBlock:(void(^)(void))block;

/**
删除全部内容
 */
- (void)removeAllObjectsWithProgressBlock:(nullable void(^)(int removedCount, int totalCount))progress
                                 endBlock:(nullable void(^)(BOOL error))end;


/**
主线程缓存总对象数
 */
- (NSInteger)totalCount;

/**
缓存总对象数
 */
- (void)totalCountWithBlock:(void(^)(NSInteger totalCount))block;

/**
总空间 单位（bytes）（阻塞线程）
 */
- (NSInteger)totalCost;

/**
 总空间
 */
- (void)totalCostWithBlock:(void(^)(NSInteger totalCost))block;


#pragma mark - Trim
///=============================================================================
/// @name Trim
///=============================================================================

/**
 从缓存中删除对象，直到“totalCount”低于指定值。
 这个方法可以阻塞调用线程，直到操作完成为止。
 */
- (void)trimToCount:(NSUInteger)count;

/**
 从缓存中删除对象，直到“totalCount”低于指定值。（子线程）
 
 @param count  允许址.
 @param block  成功后操作.
 */
- (void)trimToCount:(NSUInteger)count withBlock:(void(^)(void))block;

/**
 从缓存中删除对象
 */
- (void)trimToCost:(NSUInteger)cost;

/**
 从缓存中删除对象，直到“totalCost”低于指定值。
 此方法将立即返回并调用后台队列中的已传递块
 
 @param cost 指定值
 @param block  成功后操作.
 */
- (void)trimToCost:(NSUInteger)cost withBlock:(void(^)(void))block;

/**
 从缓存中删除对象，
 */
- (void)trimToAge:(NSTimeInterval)age;

/**
 从缓存中删除对象，直到所有到期对象被指定值删除。
 此方法将立即返回并调用后台队列中的已传递块
 
 @param age  指定时间
 @param block  成功后操作
 */
- (void)trimToAge:(NSTimeInterval)age withBlock:(void(^)(void))block;


#pragma mark - Extended Data
///=============================================================================
/// @name Extended Data
///=============================================================================

/**
 从对象中获得扩展的数据。
 */
+ (nullable NSData *)getExtendedDataFromObject:(id)object;

/**
 保存对象的扩展数据。

 */
+ (void)setExtendedData:(nullable NSData *)extendedData toObject:(id)object;

@end

NS_ASSUME_NONNULL_END

