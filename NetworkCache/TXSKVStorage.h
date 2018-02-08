//
//  TXSKVStorage.h
//  TXSCacheManager
//
//  Created by Mac on 2017/11/27.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TXSGetCache.h"

NS_ASSUME_NONNULL_BEGIN

/**
 YYKVStorageItem 保存缓存相关参数
 */
@interface TXSKVStorageItem : NSObject
@property (nonatomic, strong) NSString *key;                ///<缓存键值
@property (nonatomic, strong) NSData *value;                ///< 缓存对象
@property (nullable, nonatomic, strong) NSString *filename; ///缓存文件名
@property (nonatomic) int size;                             ///缓存大小
@property (nonatomic) int modTime;                          ///修改时间
@property (nonatomic) int accessTime;                       ///最后使用时间
@property (nullable, nonatomic, strong) NSData *extendedData; ///<拓展数据
@end

/**
 指定缓存类型
 */
typedef NS_ENUM(NSUInteger, TXSKVStorageType) {
    /// 文件缓存 （filename != null）
    TXSKVStorageTypeFile = 0,
    /// 数据库缓存
    TXSKVStorageTypeSQLite = 1,
    /// 如果filename != null, 则value 用文件缓存， 缓存的其他参数用数据库缓存； 如果filename == nil 则用数据库缓存
    TXSKVStorageTypeMixed = 2,
};



/**
缓存操作实现
 */
@interface TXSKVStorage : NSObject

#pragma mark - Attribute

@property (nonatomic, readonly) NSString *path;        ///< 缓存路径
@property (nonatomic, readonly) TXSKVStorageType type;  ///< 缓存 方式
@property (nonatomic, assign) TXSCacheManageType cachePathType;// 缓存路径类型
@property (nonatomic, strong) TXSCache *cacheManage;// 缓存路径
@property (nonatomic) BOOL errorLogsEnabled;           ///是否要打开错误ri zhi

#pragma mark - Initializer
///这两个方法不能用 因为事例化要有 path type  这里是为了 禁用
/// @name Initializer
///=============================================================================
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 实例化对象
 
 @param path  缓存路径
 @param type  缓存方式
 @return  返回对象
 @warning 不要有相同路径的多个对象.
 */
- (instancetype)initWithPath:(NSString *)path type:(TXSKVStorageType)type cacheType:(TXSCacheManageType)cachePathType NS_DESIGNATED_INITIALIZER;


#pragma mark - Save Items
///=============================================================================
/// @name Save Items
///=============================================================================

/**
 添加缓存
 
 @param item  把缓存数据封装到YYKVStorageItem 对象.
 @return 是否成功.
 */
- (BOOL)saveItem:(TXSKVStorageItem *)item;

/**
 添加缓存
 
 @param key   缓存键值.
 @param value 缓存对象.
 @return 是否成功.
 */
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value;

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

/**
 清空所有缓存（在子线程）

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
///=============================================================================
/// @name Get Items
///=============================================================================

/**
 读取缓存
 
 @param key 指定key.
 @return Item 返回对象.
 */
- (nullable TXSKVStorageItem *)getItemForKey:(NSString *)key;

///**
// 读取缓存
// 
// @param key 指定键值
// @return Item 返回对象.
// */
//- (nullable TXSKVStorageItem *)getItemInfoForKey:(NSString *)key;
//
///**
// 返回键值对内容
// 
// @param key  指定键值
// @return Item's 内容.
// */
//- (nullable NSData *)getItemValueForKey:(NSString *)key;
//
///**
// 获取键值对数组的内容
// 
// @param keys  一个键值对数组
// @return 数组<YYKVStorageItem *>
// */
//- (nullable NSArray<TXSKVStorageItem *> *)getItemForKeys:(NSArray<NSString *> *)keys;
//
///**
// 获取内容
// 
// @param keys  键值对数组
// @return 数组<YYKVStorageItem *>
// */
//- (nullable NSArray<TXSKVStorageItem *> *)getItemInfoForKeys:(NSArray<NSString *> *)keys;
//
///**
// 获取内容
// 
// @param keys  指定的key
// @return 含有键值对的字典
// */
//- (nullable NSDictionary<NSString *, NSData *> *)getItemValueForKeys:(NSArray<NSString *> *)keys;

#pragma mark - Get Storage Status
///=============================================================================
/// @name Get Storage Status
///=============================================================================

/**
 判断当前key是否有对应缓存
 
 @param key  指定键值
 
 @return 是否有
 */
- (BOOL)itemExistsForKey:(NSString *)key;

/**
 获取缓存总数量
 */
- (int)getItemsCount;

/**
 获取内存总内存开销
 */
- (int)getItemsSize;


@end
NS_ASSUME_NONNULL_END
