//
//  TXSFileCache.m
//  TXSYYCacheManager
//
//  Created by Mac on 2018/1/23.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "TXSFileCache.h"

static NSString *const kDataDirectoryName = @"data";
static NSString *const kTrashDirectoryName = @"trash";

@implementation TXSFileCache

{
    dispatch_queue_t _trashQueue;
    
    NSString *_path;
    NSString *_dataPath;
    NSString *_trashPath;
    
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    _dataPath = [path stringByAppendingPathComponent:kDataDirectoryName];
    _trashPath = [path stringByAppendingPathComponent:kTrashDirectoryName];
    _trashQueue = dispatch_queue_create("com.ibireme.cache.disk.trash", DISPATCH_QUEUE_SERIAL);
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error] ||
        ![[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:kDataDirectoryName]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error] ||
        ![[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:kTrashDirectoryName]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
            NSLog(@"YYKVStorage init error:%@", error);
            return nil;
        }
    
    [self fileEmptyTrashInBackground]; // empty the trash if failed at last time

    return self;
}
#pragma mark - file

- (BOOL)fileWriteWithName:(NSString *)filename data:(NSData *)data {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [data writeToFile:path atomically:NO];
}

- (NSData *)fileReadWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}
// 删除文件
- (BOOL)fileDeleteWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (BOOL)fileMoveAllToTrash {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *tmpPath = [_trashPath stringByAppendingPathComponent:(__bridge NSString *)(uuid)];
    BOOL suc = [[NSFileManager defaultManager] moveItemAtPath:_dataPath toPath:tmpPath error:nil];
    if (suc) {
        suc = [[NSFileManager defaultManager] createDirectoryAtPath:_dataPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    CFRelease(uuid);
    return suc;
}

- (void)fileEmptyTrashInBackground {
    NSString *trashPath = _trashPath;
    dispatch_queue_t queue = _trashQueue;
    dispatch_async(queue, ^{
        NSFileManager *manager = [NSFileManager new];
        NSArray *directoryContents = [manager contentsOfDirectoryAtPath:trashPath error:NULL];
        for (NSString *path in directoryContents) {
            NSString *fullPath = [trashPath stringByAppendingPathComponent:path];
            [manager removeItemAtPath:fullPath error:NULL];
        }
    });
}

#pragma mark - 子类实现

#pragma mark - Save Items

- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
               filename:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData {
    return [self fileWriteWithName:key data:value];
}

#pragma mark - Remove Items
- (BOOL)removeItemForKey:(NSString *)key {
    return [self fileDeleteWithName:key];
}

- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys {
    BOOL reslut = NO;
    for (NSString *key in keys) {
       reslut = [self fileDeleteWithName:key];
        if (!reslut) {
            return reslut;
        }
    }
    return YES;
}


/**
 清空所有缓存
 
 @return 是否成功.
 */
- (BOOL)removeAllItems {
   BOOL result = [self fileMoveAllToTrash];
    [self fileEmptyTrashInBackground];
    return result;
}


#pragma mark - Get Items
/**
 读取缓存
 
 @param key 指定key.
 @return Item 返回对象.
 */
- (nullable TXSKVStorageItem *)getItemForKey:(NSString *)key {
    TXSKVStorageItem *item = [TXSKVStorageItem new];
    item.value = [self fileReadWithName:key];
    item.key = key;
    return item;
}


#pragma mark - Get Storage Status

- (BOOL)itemExistsForKey:(NSString *)key {
    NSData *data = [self fileReadWithName:key];
    if (data) {
        return YES;
    }
    return NO;
}

/**
 获取缓存总数量
 */
- (int)getItemsCount {
    __block NSUInteger count = 0;
    dispatch_sync(_trashQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.path];
        count = [[fileEnumerator allObjects] count];
    });
    return (int)count;
}

/**
 获取内存总内存开销
 */
- (int)getItemsSize {
    __block NSUInteger size = 0;
    dispatch_sync(_trashQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.path];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return (int)size;
}


@end
