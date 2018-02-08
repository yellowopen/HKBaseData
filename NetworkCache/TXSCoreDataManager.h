//
//  TXSCoreDataManager.h
//  缓存测试
//
//  Created by Mac on 2018/1/26.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface TXSCoreDataManager : NSManagedObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSData *value;
@end
