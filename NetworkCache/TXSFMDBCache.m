//
//  TXSFMDBCache.m
//  缓存测试
//
//  Created by Mac on 2018/1/24.
//  Copyright © 2018年 Mac. All rights reser                                                                               ed.
//


#import <UIKit/UIKit.h>

#import "TXSFMDBCache.h"
#import "FMDB.h"

static UIApplication *_TXSShareApplication() {
    static BOOL isAppExtension = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"UIApplication");
        if(!cls || ![cls respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) isAppExtension = YES;
    });
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return isAppExtension ? nil : [UIApplication performSelector:@selector(sharedApplication)];
#pragma clang diagnostic pop
}

static NSString *const kDBFileName                     = @"FMDBmanifest.sqlite";
static NSString *const kDBTableName                    = @"fmdbtable";
static NSString *const CREAT_TABLE_IFNOT_EXISTS        = @"create table if not exists %@ (key text primary key, data blob)";
static NSString *const DELETE_DATA_WITH_PRIMARYKEY     = @"delete from %@ where key = ?";
static NSString *const INSERT_TO_TABLE                 = @"insert or replace into %@ (key, data) values (?, ?)";
static NSString *const READ_DATA_TABLE_WITH_PRIMARYKEY = @"select data from %@ where key = ?";
static NSString *const READ_ALL_DATA                   = @"select data from %@";
static NSString *const UPDATE_DATA_WHTH_PRIMARYKEY     = @"update %@ set data = ? where key = ?";
static NSString *const CLEAR_ALL_DATA                  = @"DELETE FROM %@";

@interface TXSFMDBCache()

@property (nonatomic, strong) NSString *dbPath;
@property (nonatomic, strong)FMDatabaseQueue *dbQueue;
@property (nonatomic, strong)FMDatabase *db;
@end

@implementation TXSFMDBCache

- (instancetype)initWithPath:(NSString *)path {
    self = [super initWithPath:path];
    
    self.dbPath = [path stringByAppendingPathComponent:kDBFileName];
    
    FMDatabase *fmdb = [FMDatabase databaseWithPath:self.dbPath];
    
    if ([fmdb open]) {
        self.db = fmdb;
    } else {// 失败
        [fmdb close];
    }
    return self;
}

- (void)dealloc {
    UIBackgroundTaskIdentifier taskID = [_TXSShareApplication() beginBackgroundTaskWithExpirationHandler:^{}];
    [self.db close];
    if (taskID != UIBackgroundTaskInvalid) {
        [_TXSShareApplication() endBackgroundTask:taskID];
    }
}

#pragma mark - 子类方法实现
- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
               filename:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData {
    return [self addDataWithTableName:kDBTableName primaryKey:key data:value];
}

#pragma mark - Remove Items
- (BOOL)removeItemForKey:(NSString *)key {
    return [self deleteDataWithTableName:kDBTableName primaryKey:key];
}

- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys {
    BOOL reslut = NO;
    for (NSString *key in keys) {
        reslut = [self removeItemForKey:key];
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
    BOOL result = [self clearDataBaseWithTableName:kDBTableName];
    return result;
}


#pragma mark - Get Items
/**
 读取缓存
 
 @param key 指定key.
 @return Item 返回对象.
 */
- (nullable TXSKVStorageItem *)getItemForKey:(NSString *)key {
    
    return [self readDataWithTableName:kDBTableName primaryKey:key];
}


#pragma mark - Get Storage Status

- (BOOL)itemExistsForKey:(NSString *)key {
    return [self getItemForKey:key] != NULL;
}

/**
 获取缓存总数量
 */
- (int)getItemsCount {
    if ([self.db open]) {
        NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as num FROM %@", kDBTableName];
        NSUInteger count = [self.db longForQuery:sqlstr];
        return (int)count;
    }
    return 0;
}

/**
 获取内存总内存开销
 */
- (int)getItemsSize {
    NSUInteger count = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.dbPath]) {
        count = 0;
    } else {
        count = [[fileManager attributesOfItemAtPath:self.dbPath error:nil] fileSize];
    }
    return (int)count;
}

#pragma mark - privite

//add the data by primaryKey in table
- (BOOL)addDataWithTableName:(NSString *)tableName primaryKey:(NSString *)primaryKey data:(NSData *)data {
    BOOL ret = NO;
    if ([self.db open]) {
        NSString *sql = [NSString stringWithFormat:CREAT_TABLE_IFNOT_EXISTS, tableName];
        ret = [self.db executeUpdate:sql];
        if (ret) {
            NSString *storeUrl = [NSString stringWithFormat:INSERT_TO_TABLE, tableName];
            ret = [self.db executeUpdate:storeUrl,primaryKey,data];
        }
        
    }
    [self.db close];
    return ret;
}

//delete the data by primaryKey in table
- (BOOL)deleteDataWithTableName:(NSString *)tableName primaryKey:(NSString *)primaryKey {
    BOOL ret = NO;
    if ([self.db open]) {
        NSString *sql = [NSString stringWithFormat:CREAT_TABLE_IFNOT_EXISTS, tableName];
        ret = [self.db executeUpdate:sql, primaryKey];
        if (ret) {
            NSString *deleteSql = [NSString stringWithFormat:DELETE_DATA_WITH_PRIMARYKEY,tableName];
            ret = [self.db executeUpdate:deleteSql,primaryKey];
        }
    }
    [self.db close];
    return ret;
}

//update data by primaryKey in table
- (BOOL)updateDataWithTableName:(NSString *)tableName primaryKey:(NSString *)primaryKey data:(NSData *)data {
    BOOL ret = false;
    if ([self.db open]) {
        NSString *sql = [NSString stringWithFormat:CREAT_TABLE_IFNOT_EXISTS,tableName];
        ret = [self.db executeUpdate:sql,primaryKey];
        if (ret) {
            NSString *updateSql = [NSString stringWithFormat:UPDATE_DATA_WHTH_PRIMARYKEY,tableName];
            ret = [self.db executeUpdate:updateSql,data,primaryKey];
        }
    }
    [self.db close];
    return ret;
}

//read the data by primaryKey in table
- (TXSKVStorageItem *)readDataWithTableName:(NSString *)tableName primaryKey:(NSString *)primaryKey {
    TXSKVStorageItem *item = [TXSKVStorageItem new];
    item.key = primaryKey;
    BOOL ret = NO;
    if ([self.db open]) {
        NSString *creatSql = [NSString stringWithFormat:CREAT_TABLE_IFNOT_EXISTS,tableName];
        ret = [self.db executeUpdate:creatSql];
        if (ret) {
            NSString *readSql = [NSString stringWithFormat:READ_DATA_TABLE_WITH_PRIMARYKEY,tableName];
            FMResultSet *resultSet = [self.db executeQuery:readSql,primaryKey];
            while ([resultSet next]) {
                NSData *data = [resultSet dataForColumn:@"data"];
                if (!data) {
                    return nil;
                }
                item.value = data;
                
            }
        }
    }
    [self.db close];
    return item;
}

//clear the dataBase
- (BOOL)clearDataBaseWithTableName:(NSString *)tableName {
    BOOL ret = false;
    if ([self.db open]) {
        NSString *clearSql = [NSString stringWithFormat:CLEAR_ALL_DATA,tableName];
        ret = [self.db executeUpdate:clearSql];
    }
    [self.db close];
    return ret;
}

@end
