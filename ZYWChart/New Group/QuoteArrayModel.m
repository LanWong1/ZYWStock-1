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
//订阅回报通知
- (void)quoteDataChange:(NSNotification *)notify{
  
    
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        __block NSInteger findModelIdx = 0;
        if(_quoteModelArray.count>0){
            NSLog(@"i am the king a      s  s s ss   ");
            
            [_quoteModelArray enumerateObjectsUsingBlock:^(__kindof QuoteModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"obj.instrumentID ===== %@   message = ==  %@",obj.instrumenID,notify.userInfo[@"message"][1]);
                //array中包含了此合约的model
                if([obj.instrumenID isEqualToString:notify.userInfo[@"message"][1]]){
                    obj.lastPrice = notify.userInfo[@"message"][4];//最新价
                    obj.openInterest = notify.userInfo[@"message"][13];//持仓量
                    obj.preSettlementPrice = notify.userInfo[@"message"][5];
                    [obj calculatePriceChange];//涨幅
                    findModelIdx = idx;
                    NSLog(@"findmodel index事实上哈哈哈哈 ===== %ld",idx);
                    *stop = YES;
                }
                //遍历完没有找到相同的合约号 遍历到最后一个
                if((idx== _quoteModelArray.count-1) && (findModelIdx!= _quoteModelArray.count-1)){
                    QuoteModel *model = [[QuoteModel alloc]initWithArray:notify.userInfo[@"message"]];
                    [_quoteModelArray addObject:model];
                    findModelIdx = _quoteModelArray.count - 1;
                    NSLog(@"findmodel index+++++++++++ ===== %ld",(long)findModelIdx);
                }
                
            }];
        }
        else{
            QuoteModel *model = [[QuoteModel alloc]initWithArray:notify.userInfo[@"message"]];
            NSLog(@"i am the best ahahahhhhhhhhhh");
            [_quoteModelArray addObject:model];
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            if(_delegate && [_delegate respondsToSelector:@selector(reloadData: index:)]){
                NSLog(@"findmodel index ===== %ld",(long)findModelIdx);
                [_delegate reloadData:_quoteModelArray index:findModelIdx];
            }
            if(_delegate && [_delegate respondsToSelector:@selector(quoteViewRefresh:)]){
                [_delegate quoteViewRefresh:_quoteModelArray];
            }
        });
    });
   
  
   
    
}
@end
