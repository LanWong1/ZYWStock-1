//
//  CodeListCoreData.m
//  ZYWChart
//
//  Created by zdqh on 2018/11/14.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "CodeListCoreData.h"
#import "CodeListCoreData.h"
//#import "NoteManagedObject+CoreDataProperties.h"


@implementation CodeListCoreData

@synthesize persistentContainer = _persistentContainer;





//#全局变量 单例模式
static CodeListCoreData *sharedSingleton = nil;
//#类方法 "+"
+ (CodeListCoreData *)sharedInstance {
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        sharedSingleton = [[self alloc] init];
        //初始化DateFormatter
       // sharedSingleton.dateFormatter = [[NSDateFormatter alloc] init];
        //[sharedSingleton.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return sharedSingleton;
}




- (NSPersistentContainer *)persistentContainer{
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"MyFavoriteCodeModel"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"持久化存储容器错误：%@", error.localizedDescription);
                    abort();
                }
            }];
        }
    }
    return _persistentContainer;
}


//插入code方法
- (int)create:(MyFavoriteModel *)model {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;//获取上下文
    //插入 增加数据  创建对象 操作实体的对象
    NSManagedObject *myFavoriteCode = [NSEntityDescription insertNewObjectForEntityForName:@"Code" inManagedObjectContext:context];
    
    [myFavoriteCode setValue:model.code forKey:@"code"];
    [myFavoriteCode setValue:@(model.index) forKey:@"index"];
    

    //保存数据
    [self saveContext];
    
    return 0;
}


//删除code方法
- (int)remove:(NSString*)code {
    
    //#获取上下文
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Code" inManagedObjectContext:context];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"code = %@", code];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    //执行查询
    NSArray *listData = [context executeFetchRequest:request error:&error];
    
    if (error == nil && [listData count] > 0) {
        NSManagedObject *myCode = [listData lastObject];
        [context deleteObject:myCode];
        //保存数据
        [self saveContext];
    }
    return 0;
}

//查询所有数据方法
- (NSArray *)findAll {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;//获取上下文
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Code" inManagedObjectContext:context];//实体
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;//创建request
    NSError *error = nil;
    
    //执行查询
    NSArray *listData = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        return nil;
    }
    NSMutableArray *resListData = [[NSMutableArray alloc] init];
    for (NSManagedObject *mo in listData) {
        
        MyFavoriteModel *myCode = [[MyFavoriteModel alloc] initWithCode:[mo valueForKey:@"code"] index:[[mo valueForKey:@"index"] integerValue]];
        
        [resListData addObject:myCode];
    }
    NSArray *codeList = [NSArray arrayWithArray:resListData];
    return codeList;
}
- (void)saveContext{
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    
    
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"数据保存错误：%@", error.localizedDescription);
        abort();
    }
}

//按照主键查询数据方法
- (MyFavoriteModel *)findById:(MyFavoriteModel *)model {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = entity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat: @"code = %@",model.code];
    NSError *error = nil;
    NSArray *listData = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error == nil && [listData count] > 0) {
        NSManagedObject *mo = [listData lastObject];
        MyFavoriteModel *code = [[MyFavoriteModel alloc] initWithCode:[mo valueForKey:@"code"] index:[[mo valueForKey:@"index"]integerValue]];
        return code;
    }
    return nil;
}

@end
