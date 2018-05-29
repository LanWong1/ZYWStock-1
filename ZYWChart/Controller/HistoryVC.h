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
@interface HistoryVC : UIViewController{
@private
    id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
@public
    WpQuoteServerDayKLineList *KlineList;
}

@property (nonatomic,copy)   NSMutableArray *scodeArray;


@end
