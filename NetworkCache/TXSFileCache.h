//
//  TXSFileCache.h
//  TXSYYCacheManager
//
//  Created by Mac on 2018/1/23.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "TXSCache.h"

@interface TXSFileCache : TXSCache
- (BOOL)fileWriteWithName:(NSString *)filename data:(NSData *)data ;

- (NSData *)fileReadWithName:(NSString *)filename ;
// 删除文件
- (BOOL)fileDeleteWithName:(NSString *)filename ;

- (BOOL)fileMoveAllToTrash ;

- (void)fileEmptyTrashInBackground ;

@end
