//
//  TXSCache.h
//  TXSYYCacheManager
//
//  Created by Mac on 2018/1/23.
//  Copyright © 2018年 Mac. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "TXSKVStorage.h"

NS_ASSUME_NONNULL_BEGIN

@class TXSFileCache;

@interface TXSCache : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) TXSFileCache *fileCache; // 缓存文件
@property (nonatomic, assign) TXSKVStorageType type;  ///< 缓存 方式


- (instancetype)initWithPath:(NSString *)path;

@property (nonatomic) BOOL errorLogsEnabled;           ///是否要打开错误ri zhi

#pragma mark - TXSSQLCache 私有

- (NSString *)dbGetFilenameWithKey:(NSString *)key;

#pragma mark - Save Items
/**
 添加缓存（增删改 ⚠️ 更改需要在这个方法里实现）
 
 @param key             缓存键值
 @param value         缓存对象.
 @param filename      缓存文件名称.
 filename     != null 用文件缓存value，并把`key`,`filename`,`extendedData`写入数据库
 filename     == null
 *                          缓存方式type：YYKVStorageTypeFile 不进行缓存
 *                          缓存方式type：YYKVStorageTypeSQLite || YYKVStorageTypeMixed 数据库缓存
 @param extendedData  缓存拓展数据
 @return 是否成功.
 */
- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
               filename:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData;

#pragma mark - Remove Items
///=============================================================================
/// @name Remove Items
///=============================================================================

/**
 删除缓存
 
 @param key 键值
 @return 是否成功
 */
- (BOOL)removeItemForKey:(NSString *)key;

/**
 删除缓存
 
 @param keys 键值数组.
 
 @return 是否成功.
 */
- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys;


/**
 清空所有缓存
 
 @return 是否成功.
 */
- (BOOL)removeAllItems;

/**
 删除所有缓存
 
 @param progress 进度
 @param end      结束后
 */
- (void)removeAllItemsWithProgressBlock:(nullable void(^)(int removedCount, int totalCount))progress
                               endBlock:(nullable void(^)(BOOL error))end;


#pragma mark - Get Items
/**
 读取缓存
 
 @param key 指定key.
 @return Item 返回对象.
 */
- (nullable TXSKVStorageItem *)getItemForKey:(NSString *)key;


#pragma mark - Get Storage Status
/**
 判断当前key是否有对应缓存
 
 @param key  指定键值
 
 @return 是否有
 */
- (BOOL)itemExistsForKey:(NSString *)key;

/**
 获取缓存总数量(键值对的数量)
 */
- (int)getItemsCount;

/**
 获取内存总内存开销
 */
- (int)getItemsSize;


#pragma mark - 优化缓存(如果有就使用)

/**
 删除所有内存开销大于size 的缓存.
 
 @param size  最大字节数.
 @return Whether succeed.
 */
- (BOOL)removeItemsLargerThanSize:(int)size;

/**
 删除所有比time 小的缓存.
 
 @param time  指定的时间.
 @return 是否成功.
 */
- (BOOL)removeItemsEarlierThanTime:(int)time;

/**
 R减小缓存占的容量开销，使总缓存的容量开销值不大于maxSize(删除原则：LRU 最久未使用的缓存将先删除)
 
 @param maxSize 最大字节数.
 @return 是否成功.
 */
- (BOOL)removeItemsToFitSize:(int)maxSize;

/**
 减小总缓存数量，使总缓存数量不大于maxCount(删除原则：LRU 最久未使用的缓存将先删除)
 
 @param maxCount The specified item count.
 @return Whether succeed.
 */
- (BOOL)removeItemsToFitCount:(int)maxCount;

@end


NS_ASSUME_NONNULL_END
