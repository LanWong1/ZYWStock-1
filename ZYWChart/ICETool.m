//
//  ICETool.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/11.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "ICETool.h"
#import "WpTrade.h"


@interface WpTradeAPIServerCallbackReceiverI : WpTradeAPIServerCallbackReceiver<WpTradeAPIServerCallbackReceiver>
@end
@implementation WpTradeAPIServerCallbackReceiverI
- (void)SendMsg:(NSMutableString *)stype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current {
    NSLog(@"哈哈哈  %@",strMessage);
}
@end


@interface ICETool()
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<WpTradeAPIServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<WpTradeAPIServerClientApiPrx> WpTrade;

@end

@implementation ICETool

- (void)Connect2ICE{
    ICEInitializationData* initData = [ICEInitializationData initializationData];
    initData.properties = [ICEUtil createProperties];
    [initData.properties load:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"config.client"]];
    initData.dispatcher = ^(id<ICEDispatcherCall> call, id<ICEConnection> con)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{ [call run]; });
    };
    self.communicator = [ICEUtil createCommunicator:initData];//创建communicator
    //连接
    self.router = [GLACIER2RouterPrx checkedCast:[self.communicator getDefaultRouter]];//路由
    [self.router createSession:@"" password:@""];//创建session
    //self.NpTrade = [NpTradeAPIServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];
    self.WpTrade = [WpTradeAPIServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];
    //启用主推回报
    ICEIdentity* callbackReceiverIdent= [ICEIdentity identity:@"callbackReceiver" category:[self.router getCategoryForClient]];
    id<ICEObjectAdapter> adapter = [self.communicator createObjectAdapterWithRouter:@"" router:self.router];
    [adapter activate];
    self.twowayR = [WpTradeAPIServerCallbackReceiverPrx uncheckedCast:[adapter add:[[WpTradeAPIServerCallbackReceiverI alloc]init] identity:callbackReceiverIdent]];
}
- (void)queryOrder:(NSString*)StrCmd{
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    // NpTradeAPIServerMutableSTRLIST* outList = [[NpTradeAPIServerMutableSTRLIST alloc]initWithCapacity:0];
    WpTradeAPIServerMutableSTRLIST* outList= [[WpTradeAPIServerMutableSTRLIST alloc]initWithCapacity:0];
    //[self.NpTrade QueryFund:@"" strCmd:self.loginStrCmd ListEntrust:&outList strOut:&strOut strErrInfo:&strErroInfo];
    [self.WpTrade QueryFund:@"" strCmd:StrCmd ListFund:&outList strOut:&strOut strErrInfo:&strErroInfo];
    // [self.NpTrade QueryFund:@"" strCmd:self.loginStrCmd ListFund:&outList strOut:&strOut strErrInfo:&strErroInfo];
   // return outList;
}
- (void)initiateCallback:(NSString*)strAcc{
    self.strAcc = [[NSMutableString alloc]initWithFormat:@"%@%@%@",self.strFundAcc,@"=",self.strUserId ];
    [self.WpTrade initiateCallback:strAcc proxy:self.twowayR];
}
- (void)Login:(NSString*)StrCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    //[self.NpTrade Login:@"" strCmd:_loginStrCmd strOut:&strOut strErrInfo:&strErroInfo];
    [self.WpTrade Login:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
}


@end
