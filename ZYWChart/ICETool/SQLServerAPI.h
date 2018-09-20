//
//  SQLServerAPI.h
//  ZYWChart
//
//  Created by zdqh on 2018/9/14.
//  Copyright © 2018年 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>
#import "SqlServer.h"




@class ICEInitializationData;
@protocol ICECommunicator;
@protocol GLACIER2RouterPrx;






@interface SQLServerAPI : NSObject

@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<SqlServerPublisherPrx> SQL;
@property (nonatomic) id<ICEConnection> connection;
@property (nonatomic) SqlServerSqlParameter *SqlParameter;
@property (nonatomic,strong)  SqlServerMutableSQLPARAMETERSEQUENCE *paremetersSeq;




- (void)Connect2ICE;
+ (SQLServerAPI*)shareInstance;
- (int)heartBeat;
- (void)DBAddSqlParameter:(NSString*) parameterName direction: (SqlServerParameterDirection) direction value: (NSString *)parameterValue;
@end
