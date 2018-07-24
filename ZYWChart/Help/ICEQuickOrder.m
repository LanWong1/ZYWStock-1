//
//  ICEQuickOrder.m
//  ZYWChart
//
//  Created by IanWong on 2018/7/17.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "ICEQuickOrder.h"
#import "QuickOrder.h"
#import <objc/Ice.h>
#import <objc/Glacier2.h>


@interface autoTradeCallbackReceiver()<AutoTradeCtpCallbackReceiver>
//@property (nonatomic) NSMutableArray* Msg;
//@property (nonatomic) BuyVC* buy;
@end

@implementation autoTradeCallbackReceiver

- (void)SendMsg:(ICEInt)itype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current{
    
    NSLog(@"autoTrade  %@",strMessage);
}
@end


@interface ICEQuickOrder()

@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<AutoTradeCtpCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
//@property (nonatomic) id<AutoTradeCtpClientApiPrx> quickOrder;
@property (nonatomic) NSMutableString* Message;
@property (nonatomic)  autoTradeCallbackReceiver* callbackReceiver;

@end

@implementation ICEQuickOrder
- (autoTradeCallbackReceiver*)Connect2ICE{
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
    //self.NpTrade = [NpTradeAPIServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];
    self.quickOrder = [AutoTradeCtpClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];
    //启用主推回报
    ICEIdentity* callbackReceiverIdent= [ICEIdentity identity:@"callbackReceiver" category:[self.router getCategoryForClient]];
    id<ICEObjectAdapter> adapter = [self.communicator createObjectAdapterWithRouter:@"" router:self.router];
    [adapter activate];
    self.callbackReceiver = [[autoTradeCallbackReceiver alloc]init];
    self.twowayR = [AutoTradeCtpCallbackReceiverPrx uncheckedCast:[adapter add:_callbackReceiver identity:callbackReceiverIdent]];
    return self.callbackReceiver;
}





- (void)initiateCallback:(NSString*)strAcc{
    
    [self.quickOrder initiateCallback:strAcc proxy:self.twowayR];
}

//- (void)Login:(NSString*)StrCmd{
//    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//    //[self.NpTrade Login:@"" strCmd:_loginStrCmd strOut:&strOut strErrInfo:&strErroInfo];
//    [self.quickOrder Login:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
//}
//- (int)HeartBeat:(NSString*)strCmd{
//    int iRet = -2;
//    NSLog(@"hearbeat");
//    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//    iRet = [self.quickOrder HeartBeat:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
//    //iRet = [self.quickOrder begin_HeartBeat:@"" strCmd:strCmd];
//    return iRet;
//}
//- (void)sendOrder:(NSString*)StrCmdType strCmd:(NSString *)StrCmd{
//    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//    //[self.NpTrade Login:@"" strCmd:_loginStrCmd strOut:&strOut strErrInfo:&strErroInfo];
//    [self.quickOrder SendOrder:StrCmdType strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
//}
//- (void)queryOrder:(NSString *)StrCmd strout:(NSMutableString*)strOut {
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//    //NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    [self.quickOrder QueryOrder:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
//}
//- (void)queryFund:(NSString*)StrCmd{
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    [self.quickOrder QueryFund:@"" strCmd:StrCmd  strOut:&strOut strErrInfo:&strErroInfo];
//}
//- (void)queryCode:(NSString*)StrCmd{
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    [self.quickOrder QueryCode:@"" strCmd:StrCmd  strOut:&strOut strErrInfo:&strErroInfo];
//}
//- (void)clearOrder:(NSString*)StrCmd{
//    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//    [self.quickOrder ClearOrder:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
//}


@end
