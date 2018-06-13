//
//  FundDataModel.h
//  ZYWChart
//
//  Created by zdqh on 2018/6/13.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FundDataModel : NSObject

@property (nonatomic, copy)    NSString *CurrencyNo;
@property (nonatomic, copy)    NSString *TMoney;
@property (nonatomic, copy)    NSString *TBalance;
@property (nonatomic, copy)    NSString *TCanCashOut;
@property (nonatomic, copy)    NSString *RiskRate;
@property (nonatomic, copy)    NSString *AccountMarketValue;


@end
