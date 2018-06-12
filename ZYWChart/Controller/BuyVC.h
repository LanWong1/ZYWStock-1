//
//  BuyVC.h
//  ZYWChart
//
//  Created by zdqh on 2018/6/5.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICETool.h"
@protocol BuyVCDataSource <NSObject>
- (NSMutableArray*)messageForBuyVC;
@end

@interface BuyVC : UIViewController
- (instancetype)initWithICE:(ICETool*)Tool StrCmd:(NSString*)Cmd wpTradeAPIServerCallbackReceiverI:(WpTradeAPIServerCallbackReceiverI*)wpTradeAPIServerCallbackReceiverI;
@property (weak,nonatomic)id <BuyVCDataSource>dataSource;
@end
