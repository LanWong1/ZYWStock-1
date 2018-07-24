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




- (void)Login:(NSString*)StrCmd;
- (void)initiateCallback:(NSString*)strAcc;
- (int)HeartBeat:(NSString*)strCmd;
- (void)sendOrder:(NSString*)StrCmd;
- (void)queryOrder:(NSString*)StrCmd;
- (void)queryFund:(NSString*)StrCmd;
- (void)queryCode:(NSString*)StrCmd;
- (void)clearOrder:(NSString*)StrCmd;
- (void)Logout:(NSString*)StrCmd;

- (autoTradeCallbackReceiver*)Connect2ICE;
@end
