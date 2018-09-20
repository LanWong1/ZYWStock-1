//
//  ICENpTrade.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/21.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "ICENpTrade.h"
#import "NpTrade.h"
#import "BuyVC.h"

@interface NpTradeAPIServerCallbackReceiverI()<NpTradeAPIServerCallbackReceiver>
@property (nonatomic) NSMutableArray* Msg;
@property (nonatomic) BuyVC* buy;

@end


@implementation NpTradeAPIServerCallbackReceiverI

- (void)SendMsg:(NSMutableString *)sType sMsg:(NSMutableString *)strMessage current:(ICECurrent *)current {
    //NSLog(@"%@%@",stype,strMessage);
    
    if([sType isEqualToString:@"OnQryMoney"]|[sType isEqualToString:@"OnQryOrder"]|[sType isEqualToString:@"OnQryHold"]){
        if(self.Msg==nil){
            self.Msg = [[NSMutableArray alloc]initWithCapacity:0];
        }
        [self.Msg addObject: strMessage];
    }
    else if([sType isEqualToString:@"OnLogin"]){
        NSLog(@"Login");
    }
}
- (NSMutableArray*)messageForBuyVC{
    NSMutableArray* arry = [[NSMutableArray alloc]initWithCapacity:0];;
    arry = self.Msg;
    self.Msg = nil;
    return arry;
}
@end


@interface ICENpTrade()
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<NpTradeAPIServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<NpTradeAPIServerClientApiPrx> NpTrade;
@property (nonatomic) NSMutableString* Message;
@property (nonatomic)  NpTradeAPIServerCallbackReceiverI* NpTradeAPIServerCallbackReceiverI;

@end

@implementation ICENpTrade


- (NpTradeAPIServerCallbackReceiverI*)Connect2ICE{
    ICEInitializationData* initData = [ICEInitializationData initializationData];
    initData.properties = [ICEUtil createProperties];
    [initData.properties load:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"config2.client"]];
    initData.dispatcher = ^(id<ICEDispatcherCall> call, id<ICEConnection> con)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{ [call run]; });
    };
    self.communicator = [ICEUtil createCommunicator:initData];//创建communicator
    //连接
    self.router = [GLACIER2RouterPrx checkedCast:[self.communicator getDefaultRouter]];//路由
    [self.router createSession:@"" password:@""];//创建session
    //self.NpTrade = [NpTradeAPIServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];
    self.NpTrade = [NpTradeAPIServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];
    //启用主推回报
    ICEIdentity* callbackReceiverIdent= [ICEIdentity identity:@"callbackReceiver" category:[self.router getCategoryForClient]];
    id<ICEObjectAdapter> adapter = [self.communicator createObjectAdapterWithRouter:@"" router:self.router];
    [adapter activate];
    self.NpTradeAPIServerCallbackReceiverI = [[NpTradeAPIServerCallbackReceiverI alloc]init];
    
    self.twowayR = [NpTradeAPIServerCallbackReceiverPrx uncheckedCast:[adapter add:_NpTradeAPIServerCallbackReceiverI identity:callbackReceiverIdent]];
    return self.NpTradeAPIServerCallbackReceiverI;
}
- (void)initiateCallback:(NSString*)strAcc{
    
    [self.NpTrade initiateCallback:strAcc proxy:self.twowayR];
    
}
- (void)Login:(NSString*)StrCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    //[self.NpTrade Login:@"" strCmd:_loginStrCmd strOut:&strOut strErrInfo:&strErroInfo];
    [self.NpTrade Login:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
}
- (int)HeartBeat:(NSString*)strCmd{
    int iRet = -2;
    NSLog(@"hearbeat");
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    iRet = [self.NpTrade HeartBeat:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
    return iRet;
}

- (void)queryOrder:(NSString*)StrCmd{
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NpTradeAPIServerMutableSTRLIST* outList= [[NpTradeAPIServerMutableSTRLIST alloc]initWithCapacity:0];
    //[self.NpTrade QueryOrder:@"" strCmd:StrCmd ListFund:&outList strOut:&strOut strErrInfo:&strErroInfo];
    [self.NpTrade QueryOrder:@"" strCmd:StrCmd ListEntrust:&outList strOut:&strOut strErrInfo:&strErroInfo];
}
- (void)queryHold:(NSString*)StrCmd{
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NpTradeAPIServerMutableSTRLIST* outList= [[NpTradeAPIServerMutableSTRLIST alloc]initWithCapacity:0];
    [self.NpTrade QueryHold:@"" strCmd:StrCmd ListHold:&outList strOut:&strOut strErrInfo:&strErroInfo];
}
- (void)queryFund:(NSString*)StrCmd{
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NpTradeAPIServerMutableSTRLIST* outList= [[NpTradeAPIServerMutableSTRLIST alloc]initWithCapacity:0];
    [self.NpTrade QueryFund:@"" strCmd:StrCmd ListFund:&outList strOut:&strOut strErrInfo:&strErroInfo];
}
- (void)QueryBusi:(NSString*)strCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NpTradeAPIServerMutableSTRLIST* outList= [[NpTradeAPIServerMutableSTRLIST alloc]initWithCapacity:0];
    [self.NpTrade QueryBusi:@"" strCmd:strCmd ListBusi:&outList strOut:&strOut strErrInfo:&strErroInfo];
}

- (void)SendOrder:(NSString*)StrCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    [self.NpTrade SendOrder:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
}

- (void)CancelOrder:(NSString*)StrCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    [self.NpTrade CancelOrder:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
}

@end
