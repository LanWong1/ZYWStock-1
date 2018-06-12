//
//  ICETool.h
//  ZYWChart
//
//  Created by zdqh on 2018/6/11.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>
#import "WpTrade.h"

@class ICEInitializationData;
@protocol ICECommunicator;
@protocol GLACIER2RouterPrx;

@interface WpTradeAPIServerCallbackReceiverI: WpTradeAPIServerCallbackReceiver
- (NSMutableArray*)messageForBuyVC;
@end


@interface ICETool : NSObject

- (void)queryOrder:(NSString*)StrCmd;
- (void)queryFund:(NSString*)StrCmd;
- (void)initiateCallback:(NSString*)strAcc;
- (void)Login:(NSString*)StrCmd;
- (int)HeartBeat:(NSString*)strCmd;
- (WpTradeAPIServerCallbackReceiverI*)Connect2ICE;
@end


