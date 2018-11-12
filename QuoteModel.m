//
//  quoteModel.m
//  ZYWChart
//
//  Created by zdqh on 2018/10/31.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "QuoteModel.h"
#import "QuoteArrayModel.h"
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
- (void)quoteDataChange:(NSNotification *)notify{
    
    NSInteger index = [notify.userInfo[@"index"] integerValue];
    //NSLog(@"indexModel ========== %d",index);
    [QuoteArrayModel shareInstance].quoteModelArray[index] = notify.userInfo[@"model"];
    
   // NSLog(@"quoteModelArray[%d] == %@",index,[[QuoteArrayModel shareInstance].quoteModelArray[index] description]);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(reloadData:)]){
      
        [self.delegate reloadData:index];
    }
}


- (void)processWithArray:(NSArray*)array{
    
        self.instrumenID = array[1];
        self.lastPrice = array[4];
        self.preSettlementPrice = array[5];
        self.preOpenInterest = array[7];
        self.openInterest = array[13];
        self.upperLimitPrice = array[16];
        self.lowerLimitPrice = array[17];
        self.bidPrice = array[22];
        self.bidVolum = array[23];
        self.askPrice = array[24];
        self.askVolum = array[25];
        [self calculatePriceChange];
        [self calculateInterestChange];
}

- (void)calculatePriceChange{
  
    float priceChange = [self.lastPrice floatValue] - [self.preSettlementPrice floatValue];//涨幅
    float priceChangePercentage = 100*priceChange/([self.preSettlementPrice floatValue]);//涨幅百分比
    
    self.priceChangePercentage = [NSString stringWithFormat:@"%.2f%@",priceChangePercentage,@"%"];
    self.priceChange = [NSString stringWithFormat:@"%.1f",priceChange];
   
}
- (void)calculateInterestChange{
    
    
    NSInteger interestChange = [self.openInterest integerValue] - [self.preOpenInterest integerValue];
    self.openInterestChange = [NSString stringWithFormat:@"%ld",(long)interestChange ];
    
}


@end
