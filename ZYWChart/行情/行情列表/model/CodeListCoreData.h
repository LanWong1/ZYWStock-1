//
//  CodeListCoreData.h
//  ZYWChart
//
//  Created by zdqh on 2018/11/14.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MyFavoriteModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface CodeListCoreData : NSObject

//返回数据持久化
@property (readonly, strong) NSPersistentContainer *persistentContainer;
- (void)saveContext;
+ (CodeListCoreData*)sharedInstance;
//插入Note方法
-(int) create:(MyFavoriteModel*)model;

//删除Note方法
-(int) remove:(NSString*)code;

//修改Note方法
//-(int) modify:(MyFavoriteModel*)model;

//查询所有数据方法
-(NSMutableArray*) findAll;

//按照主键查询数据方法
-(MyFavoriteModel*) findById:(MyFavoriteModel*)model;

@end

NS_ASSUME_NONNULL_END
