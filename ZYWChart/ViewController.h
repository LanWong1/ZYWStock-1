//
//  ViewController.h
//  ZYWChart
//
//  Created by 张有为 on 2016/12/17.
//  Copyright © 2016年 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WpQuote.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>

@class ICEInitializationData;
@protocol ICECommunicator;
@protocol GLACIER2RouterPrx;
@interface ViewController : UIViewController{
@private
    id<ICECommunicator> communicator;
    id<WpQuoteServerCallbackReceiverPrx> twowayR;
    id<GLACIER2RouterPrx> router;
    id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
    NSString* _Acc;
    NSString* _Pass;
    NSString* _IP;
    NSString* _Mac;
    NSString* strUserId;
}


@end

