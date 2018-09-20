//
//  ContracInfoModel.h
//  ZYWChart
//
//  Created by zdqh on 2018/9/18.
//  Copyright © 2018年 IanWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContracInfoModel : NSObject

@property (nonatomic,copy) NSString* exchange_type;
@property (nonatomic,copy) NSString* contract_name;
@property (nonatomic,copy) NSString* contract_type;
@property (nonatomic,copy) NSString* contract_code;
@property (nonatomic,copy) NSString* open_limited;
@property (nonatomic,copy) NSString* close_limited;
@property (nonatomic,copy) NSString* futu_price_step;
@property (nonatomic,copy) NSString* futu_price_multiplier;
@property (nonatomic,copy) NSString* sortid;
@property (nonatomic,copy) NSString* memo;
@property (nonatomic,copy) NSString* futu_bail_rate;
@property (nonatomic,copy) NSString* enabled;

@end
