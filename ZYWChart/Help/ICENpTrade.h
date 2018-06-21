//
//  ICENpTrade.h
//  ZYWChart
//
//  Created by zdqh on 2018/6/21.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>
#import "NpTrade.h"

@class ICEInitializationData;
@protocol ICECommunicator;
@protocol GLACIER2RouterPrx;

@interface NpTradeAPIServerCallbackReceiverI: NpTradeAPIServerCallbackReceiver
- (NSMutableArray*)messageForBuyVC;
@end


@interface ICENpTrade : NSObject

- (void)queryOrder:(NSString*)StrCmd;
- (void)queryFund:(NSString*)StrCmd;
- (void)initiateCallback:(NSString*)strAcc;
- (void)Login:(NSString*)StrCmd;
- (int)HeartBeat:(NSString*)strCmd;
- (void)queryHold:(NSString*)StrCmd;
- (NpTradeAPIServerCallbackReceiverI*)Connect2ICE;
@end
