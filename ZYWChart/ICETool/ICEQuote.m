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
    NSLog(@"hahahah:%d%@",itype,strMessage);
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

//每三秒发送通知
- (void)setHeartbeat{
    // 创建GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 3 * NSEC_PER_SEC, 0); //每3秒执行
    dispatch_source_set_event_handler(_timer, ^{
        [self sendmsg];
    });
    // 开启定时器
    dispatch_resume(_timer);
}
//传递数据的
- (void)sendmsg{
    //传递通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changedata" object:self userInfo:@"KVO通知测试"];
    if(self.delegate && [self.delegate respondsToSelector:@selector(refreshTimeline:)]){
        [self.delegate refreshTimeline:@"refresh timeline"];
    }
}
- (void)dealloc{
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changedata" object:nil];
}
- (int)HeartBeat:(NSString*)strCmd{
    NSLog(@"quote heart beat");
    int iRet = -2;
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    iRet = [self.WpQuoteServerclientApiPrx HeartBeat:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
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
            NSLog(@"ret========%d string======%@ string======%@",i, string, string2);
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
    @try{
        //[self.WpQuoteServerclientApiPrx SubscribeQuote:strCmdType strCmd:strcmd strOut:&strOut strErrInfo:&strErroInfo];
        
        [self.WpQuoteServerclientApiPrx begin_UnSubscribeQuote:strCmdType strCmd:strcmd response:^(ICEInt i, NSMutableString *string, NSMutableString *string2) {
            NSLog(@"%d %@ %@",i, string, string2);
        } exception:^(ICEException *s) {
            NSLog(@"%@",s);
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
//获取timedata
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
////获取当前时间
//- (NSString*)getCurrentTime{
//    NSDate * date = [NSDate date];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"HHmmss";
//    NSString *string = [formatter stringFromDate:date];
//    NSLog(@"uiser id ==== %@",string);
//    return string;
//}

@end