//
//  ICEQuote.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/11.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "ICEQuote.h"
#import <objc/Ice.h>
#import <objc/Glacier2.h>



@interface WpQuoteServerCallbackReceiverI()<WpQuoteServerCallbackReceiver>





@end

@implementation WpQuoteServerCallbackReceiverI

- (void)SendMsg:(ICEInt)itype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current
{
    //NSLog(@"订阅消息 type:%d  strmessage = %@",itype,strMessage);
    NSArray* arr =  [strMessage componentsSeparatedByString:@","];

    //NSString *type = [NSString stringWithFormat:@"%d",itype];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"quoteNotity" object:nil userInfo:@{@"message":arr,@"type":@(itype)}];
    
}
@end

@interface ICEQuote()
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<WpQuoteServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic)  WpQuoteServerCallbackReceiverI* wpQuoteServerCallbackReceiverI;
//@property (nonatomic) WpQuoteServerDayKLineList* DLL;
//@property (nonatomic) NSTimer *timer;
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic) id<ICEConnection> connection;
@end

@implementation ICEQuote


static ICEQuote* iceQuote = nil;

+ (ICEQuote*)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (iceQuote == nil){
            iceQuote = [[self alloc]init];
        }
    });
    return iceQuote;
}

- (WpQuoteServerCallbackReceiverI*)Connect2Quote{
    
    
    if(self.router){
        
        @try{
            [self.router destroySession];
        }
        @catch(ICEException *s){
            
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
    }
    
    
    
    ICEInitializationData* initData = [ICEInitializationData initializationData];
    initData.properties = [ICEUtil createProperties];
    [initData.properties load:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"config1.client"]];
    
    initData.dispatcher = ^(id<ICEDispatcherCall> call, id<ICEConnection> con)
    {
        dispatch_sync(dispatch_get_main_queue(), ^ { [call run]; });
    };
    self.communicator = [ICEUtil createCommunicator:initData];//创建communicator
    //连接
    self.router = [GLACIER2RouterPrx checkedCast:[self.communicator getDefaultRouter]];//路由
    [self.router createSession:@"" password:@""];//创建session
    self.connection =  [self.router ice_getConnection];
    self.WpQuoteServerclientApiPrx = [WpQuoteServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];//返回具有所请求类型代理
    //启用主推回报
    ICEIdentity* callbackReceiverIdent= [ICEIdentity identity:@"callbackReceiver" category:[self.router getCategoryForClient]];
    id<ICEObjectAdapter> adapter = [self.communicator createObjectAdapterWithRouter:@"" router:self.router];
    [adapter activate];
    self.wpQuoteServerCallbackReceiverI = [[WpQuoteServerCallbackReceiverI alloc]init];
    self.twowayR = [WpQuoteServerCallbackReceiverPrx uncheckedCast:[adapter add:_wpQuoteServerCallbackReceiverI identity:callbackReceiverIdent]];
    return self.wpQuoteServerCallbackReceiverI;
}

- (WpQuoteServerDayKLineList*)GetDayKline:(NSString*) ExchangeID{
    NSString* strErr2 = @"";
    WpQuoteServerDayKLineList* DLL = [[WpQuoteServerDayKLineList alloc]init];
    NSMutableString* sExchangeID = [[NSMutableString alloc]initWithString:ExchangeID];
    @try{
        [self.WpQuoteServerclientApiPrx GetDayKLine:sExchangeID DKLL:&DLL strErrInfo:&strErr2];
    }
    @catch(ICEException* s)
    {
        NSLog(@"%@",s);
    }
    return DLL;
}

- (void)initiateCallback:(NSString*)strAcc{
    
    [self.WpQuoteServerclientApiPrx initiateCallback:strAcc proxy:self.twowayR];
}

- (void)Login:(NSString*)StrCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    int ret = [self.WpQuoteServerclientApiPrx Login:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
    NSLog(@"login%d",ret);
   // [self setHeartbeat];//设置心跳
}




- (int)HeartBeat:(NSString*)strCmd{
    
    int iRet = -2;
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    iRet = [self.WpQuoteServerclientApiPrx HeartBeat:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
    NSLog(@"quote heart beat iRet ==== %d",iRet);
    
    return iRet;
}



- (void)SubscribeQuote:(NSString *)strCmdType strCmd:(NSString *)strcmd{
//    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//    NSLog(@" strcmd == %@",strcmd);
//    int ret = [self.WpQuoteServerclientApiPrx SubscribeQuote:strCmdType strCmd:strcmd strOut:&strOut strErrInfo:&strErroInfo];
//    NSLog(@"ret ======= %d erro ====== %@  strout======= %@",ret,strErroInfo,strOut);
    @try{

        NSLog(@"开始订阅!!strCmdType = %@ strcmd = %@ ",strCmdType,strcmd);
        [self.WpQuoteServerclientApiPrx begin_SubscribeQuote:strCmdType strCmd:strcmd response:^(ICEInt i, NSMutableString *string, NSMutableString *string2) {
           // NSLog(@"ret========%d string======%@ string======%@",i, string, string2);
        } exception:^(ICEException *s) {
            NSLog(@"订阅失败 原因 %@",s);
        }];
    }
    @catch(NSException* s)
    {
        NSLog(@"订阅出错啦 %@",s);
    }
}



- (void)UnSubscribeQuote:(NSString *)strCmdType strCmd:(NSString *)strcmd{
//    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    
//        NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//        NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//        NSLog(@" strcmd == %@",strcmd);
//        int ret = [self.WpQuoteServerclientApiPrx UnSubscribeQuote:strCmdType strCmd:strcmd strOut:&strOut strErrInfo:&strErroInfo];
//        NSLog(@"ret ======= %d erro ====== %@  strout======= %@",ret,strErroInfo,strOut);
   
    
    @try{
        
        NSLog(@"unsubscribe++++++++++");
        [self.WpQuoteServerclientApiPrx begin_UnSubscribeQuote:strCmdType strCmd:strcmd response:^(ICEInt i, NSMutableString *string, NSMutableString *string2) {
            //NSLog(@"i===== %d s=====%@ s2=======%@",i, string, string2);
        } exception:^(ICEException *s) {
            NSLog(@"取消订阅失败 %@",s);
        }];
    }
    @catch(ICEException* s)
    {
        NSLog(@"%@",s);
    }
}


//获取timedata
//- (NSMutableArray*)getTimeData:(NSString*)sCode {
//    @try{
//        NSMutableString* strOut = [[NSMutableString alloc]init];
//        NSString* Code = sCode;
//        NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//        [self.WpQuoteServerclientApiPrx GetKLine:@"day" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
//        NSMutableArray* array = [NSMutableArray array];
//        if([strOut length]> 0){
//            array = [NSMutableArray array];
//            array = [[strOut componentsSeparatedByString:@"|"] mutableCopy];
//            [array removeLastObject];
//        }
//        else{
//            array = nil;
//        }
//        return array;
//    }
//    @catch(ICEException* s)
//    {
//        NSLog(@"Fail %@",s);
//    }
//}
//获取data
- (NSMutableArray*)getKlineData:(NSString*)strCmd type:(NSString*)type{
    @try{
        NSMutableString* strOut = [[NSMutableString alloc]init];
        NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
        
        [self.WpQuoteServerclientApiPrx GetKLine:type strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
        
        NSMutableArray* array = [NSMutableArray array];
        if([strOut length]> 0){
            
            array = [NSMutableArray array];
            array = [[strOut componentsSeparatedByString:@"|"] mutableCopy];
            [array removeLastObject];
        }
        else{
            NSLog(@"无数据!!!");
        }
        return array;
    }
    @catch(ICEException* s)
    {
        NSLog(@"Fail %@",s);
    }
}


@end
