//
//  ICETool.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/11.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "ICETool.h"
#import "WpTrade.h"
#import "BuyVC.h"

@interface WpTradeAPIServerCallbackReceiverI()<WpTradeAPIServerCallbackReceiver>
@property (nonatomic) NSMutableArray* Msg;
@property (nonatomic) BuyVC* buy;

@end


@implementation WpTradeAPIServerCallbackReceiverI

- (void)SendMsg:(NSMutableString *)stype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current {
    //NSLog(@"%@%@",stype,strMessage);
   
    if([stype isEqualToString:@"OnQryMoney"]){
        NSArray* arry=[strMessage componentsSeparatedByString:@"="];
        NSLog(@"%@",arry);
        if(self.Msg==nil){
            self.Msg = [[NSMutableArray alloc]initWithCapacity:0];
        }
        [self.Msg addObject: strMessage];
    }
    else if([stype isEqualToString:@"OnLogin"]){
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


@interface ICETool()
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<WpTradeAPIServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<WpTradeAPIServerClientApiPrx> WpTrade;
@property (nonatomic) NSMutableString* Message;
@property (nonatomic)  WpTradeAPIServerCallbackReceiverI* wpTradeAPIServerCallbackReceiverI;

@end

@implementation ICETool


- (WpTradeAPIServerCallbackReceiverI*)Connect2ICE{
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
    self.wpTradeAPIServerCallbackReceiverI = [[WpTradeAPIServerCallbackReceiverI alloc]init];

    self.twowayR = [WpTradeAPIServerCallbackReceiverPrx uncheckedCast:[adapter add:_wpTradeAPIServerCallbackReceiverI identity:callbackReceiverIdent]];
    return self.wpTradeAPIServerCallbackReceiverI;
}
- (void)queryOrder:(NSString*)StrCmd{
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    WpTradeAPIServerMutableSTRLIST* outList= [[WpTradeAPIServerMutableSTRLIST alloc]initWithCapacity:0];
    //[self.WpTrade QueryOrder:@"" strCmd:StrCmd ListFund:&outList strOut:&strOut strErrInfo:&strErroInfo];
    [self.WpTrade QueryOrder:@"" strCmd:StrCmd ListEntrust:&outList strOut:&strOut strErrInfo:&strErroInfo];
 
}
- (void)queryFund:(NSString*)StrCmd{
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    WpTradeAPIServerMutableSTRLIST* outList= [[WpTradeAPIServerMutableSTRLIST alloc]initWithCapacity:0];
    //[self.WpTrade QueryOrder:@"" strCmd:StrCmd ListFund:&outList strOut:&strOut strErrInfo:&strErroInfo];
    [self.WpTrade QueryFund:@"" strCmd:StrCmd ListFund:&outList strOut:&strOut strErrInfo:&strErroInfo];
}
- (void)initiateCallback:(NSString*)strAcc{

    [self.WpTrade initiateCallback:strAcc proxy:self.twowayR];
    
}
- (void)Login:(NSString*)StrCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    //[self.NpTrade Login:@"" strCmd:_loginStrCmd strOut:&strOut strErrInfo:&strErroInfo];
    [self.WpTrade Login:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
}
- (int)HeartBeat:(NSString*)strCmd{
    int iRet = -2;
    NSLog(@"hearbeat");
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    iRet = [self.WpTrade HeartBeat:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
    return iRet;
}


@end
