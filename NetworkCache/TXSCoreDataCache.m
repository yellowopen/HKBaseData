//
//  TXSCoreDataCache.m
//  缓存测试
//
//  Created by Mac on 2018/1/26.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "TXSCoreDataCache.h"
#import "TXSCoreDataManager.h"

@implementation TXSCoreDataCache
{
    NSManagedObjectContext *_objContext;//用于操作coreData数据
    NSManagedObjectModel *_objModel;//用于转化coreData文件
    NSPersistentStoreCoordinator *_storeCoordinator; //存储协调器
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super initWithPath:path];
    _objModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    //创建协调器
    _storeCoordinator  = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_objModel];
    //将coreData数据映射到数据库
    NSError *error = nil;
    NSString *dataPath = [path stringByAppendingPathComponent:@"TXSCoreData.sqlite"];
    NSPersistentStore *store = [_storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataPath] options:nil error:&error];
    if (!store) {
        NSLog(@"error:%@",error);
        //断言
        [NSException raise:@"添加数据库错误" format:@"%@", [error localizedDescription]];//错误信息本地化描述
    }
    //创建上下文托管对象
    _objContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _objContext.persistentStoreCoordinator = _storeCoordinator;
    return self;
}

//保存数据
- (void)saveContext {
    NSError *error =nil;
    if (![_objContext save:&error]) {
        NSLog(@"save_error:%@",[error localizedDescription]);
    }
    NSLog(@"保存数据成功");
}


#pragma mark - Save Items

- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
               filename:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData {
    
    NSArray *rs = [self getItemArrWithKey:key];
    if (rs.count > 0) {
        TXSCoreDataManager * coreData = [rs lastObject];
        coreData.key = key;
        coreData.value = value;
    } else {
        TXSCoreDataManager * coreData = [NSEntityDescription insertNewObjectForEntityForName:@"TXSCoreData" inManagedObjectContext:_objContext];
        coreData.key = key;
        coreData.value = value;
    }
    [self saveContext];
    return YES;
}

#pragma mark - Remove Items
- (BOOL)removeItemForKey:(NSString *)key {
    NSArray *rs = [self getItemArrWithKey:key];
    for (TXSCoreDataManager *coreData in rs ) {
        [_objContext deleteObject:coreData];
        NSLog(@"删除成功");
    }
    return YES;
}

/**
 清空所有缓存
 @return 是否成功.
 */
- (BOOL)removeAllItems {
    NSArray *rs = [self getItemArrWithKey:@""];
    for (TXSCoreDataManager *coreData in rs ) {
        [_objContext deleteObject:coreData];
        NSLog(@"删除成功");
    }
    return YES;
}

#pragma mark - Get Items
/**
 读取缓存

 @param key 指定key.
 @return Item 返回对象.
 */
- (nullable TXSKVStorageItem *)getItemForKey:(NSString *)key {
    TXSKVStorageItem *item = [TXSKVStorageItem new];
    NSArray *rs = [self getItemArrWithKey:key];
    if (rs.count > 0) {
        TXSCoreDataManager * coreData = [rs lastObject];
        item.value = coreData.value;
        item.key = key;
    }
    return item;
}

/**
 获取缓存总数量
 */
- (int)getItemsCount {
    NSArray *rs = [self getItemArrWithKey:@""];
    return (int)rs.count;
}

/**
 获取内存总内存开销
 */
- (int)getItemsSize {
    __block NSUInteger size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.path];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return (int)size;
}

/**
 获取查询结果数组
 */
- (NSArray *)getItemArrWithKey:(NSString *)key {
    //创建查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (key.length > 0) {
        //设置谓词
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"key like %@",[NSString stringWithFormat:@"%@",key]];
        request.predicate = pre;
    }
    //设置查询的模型
    request.entity = [NSEntityDescription entityForName:@"TXSCoreData" inManagedObjectContext:_objContext];
    
    //查询结果
    NSArray *rs = [_objContext executeFetchRequest:request error:nil];
    
    return rs;
}



@end
