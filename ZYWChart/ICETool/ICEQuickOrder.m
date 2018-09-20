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
   // NSLog(@"返回消息类型===%d  消息=== %@",itype,strMessage);
    NSString *type = [NSString stringWithFormat:@"%d",itype];
//    NSDictionary *note = [NSDictionary dictionaryWithObject:strMessage forKey:@"message"];
//    [note setValue:type forKey:@"type"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tradeNotify" object:nil userInfo:@{@"message":strMessage,@"type":type}];
}
@end


@interface ICEQuickOrder()

//@property (nonatomic) id<ICECommunicator> communicator;
//@property (nonatomic) id<AutoTradeCtpCallbackReceiverPrx> twowayR;
//@property (nonatomic) id<GLACIER2RouterPrx> router;
////@property (nonatomic) id<AutoTradeCtpClientApiPrx> quickOrder;
//@property (nonatomic) NSMutableString* Message;
//@property (nonatomic)  autoTradeCallbackReceiver* callbackReceiver;

@end

@implementation ICEQuickOrder

//单例模式
static ICEQuickOrder* QuickOrder = nil;

+ (ICEQuickOrder*)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (QuickOrder == nil){
            QuickOrder = [[self alloc]init];
        }
    });
    return QuickOrder;
}



- (autoTradeCallbackReceiver*)Connect2ICE{
    
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

- (int)Login:(NSString*)StrCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    //[self.NpTrade Login:@"" strCmd:_loginStrCmd strOut:&strOut strErrInfo:&strErroInfo];
    int ret = [self.quickOrder Login:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
    return ret;
}
- (int)HeartBeat:(NSString*)strCmd{
    int iRet = -2;
    NSLog(@"quickOrder hearbeat");
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    iRet = [self.quickOrder HeartBeat:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
    //iRet = [self.quickOrder begin_HeartBeat:@"" strCmd:strCmd];
    return iRet;
}
- (void)sendOrder:(NSString*)StrCmdType strCmd:(NSString *)StrCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    [self.quickOrder SendOrder:StrCmdType strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
    NSLog(@"sendOrder: strout=%@ erro = %@",strOut,strErroInfo);
}
- (void)queryOrder:(NSString *)StrCmd strout:(NSMutableString*)strOut {
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    //NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    [self.quickOrder QueryOrder:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
    NSLog(@"QueryOrder: strout=%@ erro = %@",strOut,strErroInfo);
}
- (void)queryOrder:(NSString *)StrCmd {
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    [self.quickOrder QueryOrder:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
    NSLog(@"QueryOrder: strout=%@ erro = %@",strOut,strErroInfo);
}
- (void)queryFund:(NSString*)StrCmd{
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    [self.quickOrder QueryFund:@"" strCmd:StrCmd  strOut:&strOut strErrInfo:&strErroInfo];
    NSLog(@"QueryFund: strout=%@ erro = %@",strOut,strErroInfo);
}
- (NSMutableString *)queryCode:(NSString*)StrCmd{
    
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    //__block  NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    [self.quickOrder QueryCode:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
    return strOut;
//    [self.quickOrder begin_QueryCode:@"" strCmd:StrCmd response:^(ICEInt l, NSMutableString *s, NSMutableString *a) {
//        NSLog(@"l = %d s = %@  a = %@",l,s,a);
//        [strOut appendString:s];
//    } exception:^(ICEException *s) {
//        NSLog(@"%@",s);
//    }];
   // return strOut;
}

- (void)clearOrder:(NSString*)StrCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    [self.quickOrder ClearOrder:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
    NSLog(@"ClearOrder: strout=%@ erro = %@",strOut,strErroInfo);
}


@end
