//
//  quoteModel.m
//  ZYWChart
//
//  Created by zdqh on 2018/10/31.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "QuoteModel.h"

@implementation QuoteModel
//单例模式 全局变量
static QuoteModel* quoteModel = nil;
+ (QuoteModel*)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (quoteModel == nil){
            quoteModel = [[self alloc]init];
        }
    });
    return quoteModel;
}

- (id)initWithArray:(NSArray*)array{
    self = [super init];
    if(self){
        self.instrumenID = array[1];
        self.lastPrice = array[4];
        self.preSettlementPrice = array[5];
        self.preOpenInterest = array[7];
        self.openInterest = array[13];
    }
    return self;
}

- (void)calculatePriceChange{
    NSString *priceChangeTemp;
    float price = ([self.lastPrice integerValue] - [self.preSettlementPrice integerValue])/([self.preSettlementPrice integerValue]);
    if(price<0){
        priceChangeTemp = [NSString stringWithFormat:@"%@%.2f%@",@"-",price,@"%"];
    }
    else{
        priceChangeTemp = [NSString stringWithFormat:@"%.2f",price ];
    }
    
    self.priceChange = priceChangeTemp;
}
@end
