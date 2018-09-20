//
//  ICEQuickOrder.h
//  ZYWChart
//
//  Created by IanWong on 2018/7/17.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>
#import "QuickOrder.h"


@class ICEInitializationData;
@protocol ICECommunicator;
@protocol GLACIER2RouterPrx;

@interface autoTradeCallbackReceiver: AutoTradeCtpCallbackReceiver
//- (NSMutableArray*)messageForBuyVC;
@end


@interface ICEQuickOrder : NSObject

@property (nonatomic) id<AutoTradeCtpClientApiPrx> quickOrder;

@property (nonatomic, copy) NSString* strFunAcc;
@property (nonatomic, copy) NSString* strPassword;
@property (nonatomic, copy) NSString* strUserId;

@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<AutoTradeCtpCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
//@property (nonatomic) id<AutoTradeCtpClientApiPrx> quickOrder;
@property (nonatomic) NSMutableString* Message;
@property (nonatomic)  autoTradeCallbackReceiver* callbackReceiver;
@property (nonatomic) id<ICEConnection> connection;







+ (ICEQuickOrder*)shareInstance;
- (int)Login:(NSString*)StrCmd;

- (void)initiateCallback:(NSString*)strAcc;
- (int)HeartBeat:(NSString*)strCmd;
- (void)reConnect;
- (void)sendOrder:(NSString*)StrCmdType strCmd:(NSString *)StrCmd;
- (void)queryOrder:(NSString*)StrCmd;
- (void)queryFund:(NSString*)StrCmd;
//- (void)queryCode:(NSString*)StrCmd;
- (void)clearOrder:(NSString*)StrCmd;
//- (void)Logout:(NSString*)StrCmd;
- (NSMutableString *)queryCode:(NSString*)StrCmd;
- (autoTradeCallbackReceiver*)Connect2ICE;
@end
