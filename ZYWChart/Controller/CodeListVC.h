//
//  HistoryVC.h
//  ZYWChart
//
//  Created by zdqh on 2018/5/29.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <WpQuote.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>
#import "ICEQuote.h"

//@class ICEInitializationData;
//@protocol ICECommunicator;
//@protocol GLACIER2RouterPrx;
@interface CodeListVC : UIViewController{
@private
//    id<ICECommunicator> communicator;
//    id session;
//    id<GLACIER2RouterPrx> router;
    id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
    //id<WpQuoteServerCallbackReceiverPrx> twowayR;
@public
    WpQuoteServerDayKLineList *KlineList;
}

@property (nonatomic,copy)   NSMutableArray *scodeArray;

//-(void)activate:(id<ICECommunicator>)communicator
//         router:(id<GLACIER2RouterPrx>)router
//WpQuoteServerclientApiPrx:(id<WpQuoteServerClientApiPrx>)WpQuoteServerclientApiPrx;
//
//-(void)activate:(ICEQuote*)iceQuote;


@end
