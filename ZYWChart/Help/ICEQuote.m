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



@interface WpQuoteServerCallbackReceiverI : WpQuoteServerCallbackReceiver<WpQuoteServerCallbackReceiver>
@end

@implementation WpQuoteServerCallbackReceiverI
- (void)SendMsg:(ICEInt)itype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current
{
    NSLog(@"%@",strMessage);
}
@end

@interface ICEQuote()
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<WpQuoteServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
@end

@implementation ICEQuote


- (void)Connect2Quote{

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
    self.twowayR = [WpQuoteServerCallbackReceiverPrx uncheckedCast:[adapter add:[[WpQuoteServerCallbackReceiverI alloc]init] identity:callbackReceiverIdent]];
}

- (WpQuoteServerDayKLineList*)GetDayKline{
    NSString* strErr2 = @"";
    WpQuoteServerDayKLineList* DLL = [[WpQuoteServerDayKLineList alloc]init];
    NSMutableString* sExchangeID = [[NSMutableString alloc]initWithString:@"SHFE"];
    @try{
        [self.WpQuoteServerclientApiPrx GetDayKLine:sExchangeID DKLL:&DLL strErrInfo:&strErr2];
    }
    @catch(ICEException* s)
    {
        NSLog(@"%@",s);
    }
    return DLL;
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
