//
//  HoldDataModel.h
//  ZYWChart
//
//  Created by zdqh on 2018/6/14.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HoldDataModel : NSObject
@property (nonatomic, copy)    NSString *CommodityNo;
@property (nonatomic, copy)    NSString *ContractNo;
@property (nonatomic, copy)    NSString *Direct;
@property (nonatomic, copy)    NSString *TradeVol;
@property (nonatomic, copy)    NSString *Deposit;
@property (nonatomic, copy)    NSString *YSettlePrice;
@end
