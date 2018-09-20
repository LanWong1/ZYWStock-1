//
//  SQLServerAPI.m
//  ZYWChart
//
//  Created by zdqh on 2018/9/14.
//  Copyright © 2018年 zyw113. All rights reserved.
//

#import "SQLServerAPI.h"

@interface SQLServerAPI()

@property (nonatomic,strong) dispatch_source_t timer;

@property (nonatomic,assign) int Ret;

@end


@implementation SQLServerAPI


//单例

static SQLServerAPI* sqlServerApi = nil;

+ (SQLServerAPI*)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sqlServerApi == nil){
            sqlServerApi = [[self alloc]init];
        }
    });
    return sqlServerApi;
}


- (void)Connect2ICE{
    
    if(self.router){
        @try{
            
            [self.router destroySession];
        }
        @catch(ICEException *s){
            
            NSLog(@"erro = %@",s);
        }
        self.router = nil;
    }
    if(self.communicator){
        @try{
            
            [self.communicator destroy];
        }
        @catch(ICEException *s){
            NSLog(@"erro = %@",s);
        }
        self.communicator = nil;
    }
    if(self.connection){
        @try{
            
            [self.connection close:ICEConnectionCloseForcefully];
        }
        @catch(ICEException *s){
            NSLog(@"erro = %@",s);
        }
        self.connection = nil;
    }
  
    ICEInitializationData* initData = [ICEInitializationData initializationData];
    initData.properties = [ICEUtil createProperties];
    [initData.properties load:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"config3.client"]];
    initData.dispatcher = ^(id<ICEDispatcherCall> call, id<ICEConnection> con)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{ [call run]; });
    };
    self.communicator = [ICEUtil createCommunicator:initData];//创建communicator
    //连接
    self.router = [GLACIER2RouterPrx checkedCast:[self.communicator getDefaultRouter]];//路由
    [self.router createSession:@"" password:@""];//创建session
    self.connection =  [self.router ice_getConnection];
    //self.NpTrade = [NpTradeAPIServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];
    self.SQL = [SqlServerPublisherPrx uncheckedCast:[self.communicator stringToProxy:@"IceSQLServer"]];
}


- (int)heartBeat{
    NSLog(@"sqlserver heartbeat");
    [self.SQL begin_ice_ping:^{
    } exception:^(ICEException *s) {
        NSLog(@"sqlheartbeat erro = %@",s);
        self.Ret = -2;
    }];
    return self.Ret;
}

- (void)DBAddSqlParameter:(NSString*) parameterName direction: (SqlServerParameterDirection) direction value: (NSString *)parameterValue{
    SqlServerSqlParameter * param = [SqlServerSqlParameter alloc];
    param.strParameterName = parameterName;
    param.PD = direction;
    param.strParameterValue = parameterValue;
    [self.paremetersSeq addObject:param];
    
}
@end
