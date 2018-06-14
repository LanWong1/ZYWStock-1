//
//  OrderDataModel.h
//  ZYWChart
//
//  Created by zdqh on 2018/6/14.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderDataModel : NSObject

@property (nonatomic, copy)    NSString *CommodityNo;
@property (nonatomic, copy)    NSString *ContractNo;
@property (nonatomic, copy)    NSString *OrderState;
@property (nonatomic, copy)    NSString *MatchPrice;
@property (nonatomic, copy)    NSString *MatchVol;
@property (nonatomic, copy)    NSString *OrderPrice;

@end
