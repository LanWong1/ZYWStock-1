//
//  ICEQuote.h
//  ZYWChart
//
//  Created by zdqh on 2018/6/11.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WpQuote.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>

@class ICEInitializationData;
@protocol ICECommunicator;
@protocol GLACIER2RouterPrx;

@interface WpQuoteServerCallbackReceiverI : WpQuoteServerCallbackReceiver
//- (NSMutableArray*)messageForBuyVC;
@end


@interface ICEQuote : NSObject

- (WpQuoteServerCallbackReceiverI*)Connect2Quote;
- (void)initiateCallback:(NSString*)strAcc;
- (void)Login:(NSString*)StrCmd;
- (int)HeartBeat:(NSString*)strCmd;
- (void)SubscribeQuote:(NSString*)strCmdType strCmd:(NSString*)strCmd;
- (WpQuoteServerDayKLineList*)GetDayKline:(NSString*)ExchangeID;
- (NSMutableArray*)getTimeData:(NSString*)sCode;
@end
