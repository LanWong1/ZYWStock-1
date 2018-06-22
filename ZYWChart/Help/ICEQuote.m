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
#import <WpQuote.h>


@interface WpQuoteServerCallbackReceiverI()<WpQuoteServerCallbackReceiver>
@end

@implementation WpQuoteServerCallbackReceiverI
- (void)SendMsg:(ICEInt)itype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current
{
    NSLog(@"hahahah:%d   %@",itype,strMessage);
}
@end

@interface ICEQuote()
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<WpQuoteServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
@property (nonatomic)  WpQuoteServerCallbackReceiverI* wpQuoteServerCallbackReceiverI;
//@property (nonatomic) WpQuoteServerDayKLineList* DLL;
@end

@implementation ICEQuote


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
    NSLog(@"login %d",ret);
}

- (int)HeartBeat:(NSString*)strCmd{
    int iRet = -2;
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    iRet = [self.WpQuoteServerclientApiPrx HeartBeat:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
    return iRet;
}
- (void)SubscribeQuote:(NSString *)strCmdType strCmd:(NSString *)strcmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    @try{
        [self.WpQuoteServerclientApiPrx SubscribeQuote:strCmdType strCmd:strcmd strOut:&strOut strErrInfo:&strErroInfo];
    }
    @catch(ICEException* s)
    {
        NSLog(@"%@",s);
    }
    
    //NSLog(@"strout%@%d",strOut,ret);
    //NSLog(@"erro %@",strErroInfo);
}




//获取timedata
- (NSMutableArray*)getTimeData:(NSString*)sCode {
    @try{
        // [self reconnect];//重连
        NSMutableString* strOut = [[NSMutableString alloc]init];
        NSString* Time = [self getCurrentTime];
        NSString* Code = sCode;
        NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
        NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@" ,Code,@"=",Time];
        [self.WpQuoteServerclientApiPrx GetKLine:@"minute" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
        NSMutableArray* array = [NSMutableArray array];
        if([strOut length]> 0){
            array = [NSMutableArray array];
            array = [[strOut componentsSeparatedByString:@"|"] mutableCopy];
            [array removeLastObject];
        }
        else{
            array = nil;
        }
        return array;
    }
    @catch(ICEException* s)
    {
        NSLog(@"Fail %@",s);
    }
}
//获取当前时间
- (NSString*)getCurrentTime{
    NSDate * date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HHmmss";
    NSString *string = [formatter stringFromDate:date];
    return string;
}

@end
