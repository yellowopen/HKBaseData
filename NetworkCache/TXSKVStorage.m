//
//  TXSKVStorage.m
//  TXSCacheManager
//
//  Created by Mac on 2017/11/27.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "TXSKVStorage.h"
#import <UIKit/UIKit.h>
#import <time.h>

#import "TXSFileCache.h"

static const int kPathLengthMax = PATH_MAX - 64;

/*
 File:
 /path/
 /manifest.sqlite
 /manifest.sqlite-shm
 /manifest.sqlite-wal
 /data/
 /e10adc3949ba59abbe56e057f20f883e
 /e10adc3949ba59abbe56e057f20f883e
 /trash/
 /unused_file_or_folder
 
 SQL:
 create table if not exists manifest (
 key                 text,
 filename            text,
 size                integer,
 inline_data         blob,
 modification_time   integer,
 last_access_time    integer,
 extended_data       blob,
 primary key(key)
 );
 create index if not exists last_access_time_idx on manifest(last_access_time);
 */


@implementation TXSKVStorageItem
@end
@implementation  TXSKVStorage {


}





#pragma mark - private

/**
 Delete all files and empty in background.
 Make sure the db is closed.
 */

#pragma mark - public

- (instancetype)init {
    @throw [NSException exceptionWithName:@"YYKVStorage init error" reason:@"Please use the designated initializer and pass the 'path' and 'type'." userInfo:nil];
    return [self initWithPath:@"" type:TXSKVStorageTypeFile cacheType:TXSCacheManageTypeSQL];
}

- (instancetype)initWithPath:(NSString *)path type:(TXSKVStorageType)type cacheType:(TXSCacheManageType)cachePathType {
    if (path.length == 0 || path.length > kPathLengthMax) {
        NSLog(@"YYKVStorage init error: invalid path: [%@].", path);
        return nil;
    }
    if (type > TXSKVStorageTypeMixed) {
        NSLog(@"YYKVStorage init error: invalid type: %lu.", (unsigned long)type);
        return nil;
    }
    
    self = [super init];
    _path = path.copy;
    _type = type;
    _cachePathType = cachePathType;
    _cacheManage = [TXSGetCache getCachePathWithPath:path Type:cachePathType];
    _cacheManage.type = type;
    return self;
}



- (BOOL)saveItem:(TXSKVStorageItem *)item {
    return [self saveItemWithKey:item.key value:item.value filename:item.filename extendedData:item.extendedData];
}

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value {
    return [self saveItemWithKey:key value:value filename:nil extendedData:nil];
}

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value filename:(NSString *)filename extendedData:(NSData *)extendedData {
    
   return [self.cacheManage saveItemWithKey:key value:value filename:filename extendedData:extendedData];
   
}
// 删除缓存
- (BOOL)removeItemForKey:(NSString *)key {
    if (key.length == 0) return NO;
    
   return [self.cacheManage removeItemForKey:key];
}

- (BOOL)removeItemForKeys:(NSArray *)keys {
    if (keys.count == 0) return NO;
    return  [self.cacheManage removeItemForKeys:keys];
}

- (BOOL)removeItemsLargerThanSize:(int)size {
    return [self.cacheManage removeItemsLargerThanSize:size];
}

- (BOOL)removeItemsEarlierThanTime:(int)time {
    return [self.cacheManage removeItemsEarlierThanTime:time];
}

- (BOOL)removeItemsToFitSize:(int)maxSize {
    return  [self.cacheManage removeItemsToFitSize:maxSize];
}

- (BOOL)removeItemsToFitCount:(int)maxCount {
    return [self.cacheManage removeItemsToFitCount:maxCount];
}

- (BOOL)removeAllItems {
    return [self.cacheManage removeAllItems];
}

- (void)removeAllItemsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
                               endBlock:(void(^)(BOOL error))end {
    
    [self.cacheManage removeAllItemsWithProgressBlock:progress endBlock:end];
}
// 查找缓存
- (TXSKVStorageItem *)getItemForKey:(NSString *)key {
    return [self.cacheManage getItemForKey:key];
}

- (BOOL)itemExistsForKey:(NSString *)key {
    return [self.cacheManage itemExistsForKey:key];
}

- (int)getItemsCount {
    return [self.cacheManage getItemsCount];
}

- (int)getItemsSize {
    return [self.cacheManage getItemsSize];
}

@end

