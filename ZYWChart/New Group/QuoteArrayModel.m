//
//  QuoteArrayModel.m
//  ZYWChart
//
//  Created by zdqh on 2018/11/1.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "QuoteArrayModel.h"

@implementation QuoteArrayModel
static QuoteArrayModel *quoteArrayModel;
+(QuoteArrayModel*)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(quoteArrayModel == nil){
            quoteArrayModel = [[self alloc]init];
        }
    });
    return quoteArrayModel;
}
- (void)quoteDataChange:(NSNotification *)notify{
  
    
    __block NSInteger findModelIdx;
    if(_quoteModelArray.count>0){
        
        [_quoteModelArray enumerateObjectsUsingBlock:^(__kindof QuoteModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //array中包含了此合约的model
            if([obj.instrumenID isEqualToString:notify.userInfo[@"message"][1]]){
                obj.lastPrice = notify.userInfo[@"message"][4];//最新价
                obj.openInterest = notify.userInfo[@"message"][13];//持仓量
                obj.preSettlementPrice = notify.userInfo[@"message"][5];
                [obj calculatePriceChange];//涨幅
                findModelIdx = idx;
                *stop = YES;
            }
            //遍历完没有找到相同的合约号 遍历到最后一个
            if((idx== _quoteModelArray.count-1) && (findModelIdx!= _quoteModelArray.count-1)){
                QuoteModel *model = [[QuoteModel alloc]initWithArray:notify.userInfo[@"message"]];
                [_quoteModelArray addObject:model];
            }
        }];
    }
    else{
        QuoteModel *model = [[QuoteModel alloc]initWithArray:notify.userInfo[@"message"]];
        [_quoteModelArray addObject:model];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(reloadData:)]){
        [_delegate reloadData:_quoteModelArray];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(quoteViewRefresh:)]){
        [_delegate quoteViewRefresh:_quoteModelArray];
    }
   
    
}
@end
