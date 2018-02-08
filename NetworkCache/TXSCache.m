//
//  TXSCache.m
//  TXSYYCacheManager
//
//  Created by Mac on 2018/1/23.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "TXSCache.h"

@implementation TXSCache
- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    self.path = path;
    self.errorLogsEnabled = YES;
    return  self;
}


- (NSString *)dbGetFilenameWithKey:(NSString *)key {
    return nil;
}


#pragma mark - Save Items
///=============================================================================
/// @name Save Items
///=============================================================================

/**
 添加缓存
 
 @param item  把缓存数据封装到YYKVStorageItem 对象.
 @return 是否成功.
 */
- (BOOL)saveItem:(TXSKVStorageItem *)item {
    return NO;
}

/**
 添加缓存
 
 @param key   缓存键值.
 @param value 缓存对象.
 @return 是否成功.
 */
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value{
    return NO;
}

/**
 添加缓存
 
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
           extendedData:(nullable NSData *)extendedData{
    return NO;
}

#pragma mark - Remove Items
///=============================================================================
/// @name Remove Items
///=============================================================================

/**
 删除缓存
 
 @param key 键值
 @return 是否成功
 */
- (BOOL)removeItemForKey:(NSString *)key{
    return NO;
}

/**
 删除缓存
 
 @param keys 键值数组.
 
 @return 是否成功.
 */
- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys{
    return NO;
}

/**
 删除所有内存开销大于size 的缓存.
 
 @param size  最大字节数.
 @return Whether succeed.
 */
- (BOOL)removeItemsLargerThanSize:(int)size{
    return NO;
}

/**
 删除所有比time 小的缓存.
 
 @param time  指定的时间.
 @return 是否成功.
 */
- (BOOL)removeItemsEarlierThanTime:(int)time{
    return NO;
}

/**
 R减小缓存占的容量开销，使总缓存的容量开销值不大于maxSize(删除原则：LRU 最久未使用的缓存将先删除)
 
 @param maxSize 最大字节数.
 @return 是否成功.
 */
- (BOOL)removeItemsToFitSize:(int)maxSize{
    return NO;
}

/**
 减小总缓存数量，使总缓存数量不大于maxCount(删除原则：LRU 最久未使用的缓存将先删除)
 
 @param maxCount The specified item count.
 @return Whether succeed.
 */
- (BOOL)removeItemsToFitCount:(int)maxCount{
    return NO;
}

/**
 清空所有缓存（在子线程）
 
 @return 是否成功.
 */
- (BOOL)removeAllItems {
    return NO;
}
/**
 删除所有缓存
 
 @param progress 进度
 @param end      结束后
 */
- (void)removeAllItemsWithProgressBlock:(nullable void(^)(int removedCount, int totalCount))progress

                               endBlock:(nullable void(^)(BOOL error))end{
  
}


#pragma mark - Get Items
///=============================================================================
/// @name Get Items
///=============================================================================

/**
 读取缓存
 
 @param key 指定key.
 @return Item 返回对象.
 */
- (nullable TXSKVStorageItem *)getItemForKey:(NSString *)key{
    return nil;
}

/**
 判断当前key是否有对应缓存
 
 @param key  指定键值
 
 @return 是否有
 */
- (BOOL)itemExistsForKey:(NSString *)key{
    return NO;
}

/**
 获取缓存总数量
 */
- (int)getItemsCount{
    return 0;
}

/**
 获取内存总内存开销
 */
- (int)getItemsSize{
    return 0;
}

@end
