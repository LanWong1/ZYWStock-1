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
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(quoteDataChange:) name:@"quoteNotity" object:nil];
    });
    return quoteModel;
}
//- (void)quoteDataChange:(NSNotification *)notify{
//
//    __block NSInteger findModelIdx;
//    NSArray *array = notify.userInfo[@"message"];
//    self.instrumenID = array[1];
//    self.lastPrice = array[4];
//    self.preSettlementPrice = array[5];
//    self.preOpenInterest = array[7];
//    self.openInterest = array[13];
//    self.upperLimitPrice = array[16];
//    self.lowerLimitPrice = array[17];
//    self.bidPrice = array[22];
//    self.bidVolum = array[23];
//    self.askPrice = array[24];
//    self.askVolum = array[25];
//    [self calculatePriceChange];
//
//
//    NSArray *objectsArray = [NSArray arrayWithObjects:self.instrumenID,self.lastPrice,self.preSettlementPrice,self.preOpenInterest,self.openInterest,self.upperLimitPrice,self.lowerLimitPrice,self.bidVolum,self.bidPrice,self.askVolum,self.askPrice,self.priceChange,self.priceChangePercentage, nil];
//    NSArray *keyArray = [NSArray arrayWithObjects:@"instrumenID", @"lastPrice",@"preSettlementPrice",@"preOpenInterest",@"openInterest",@"upperLimitPrice",@"lowerLimitPrice",@"bidVolum",@"bidPrice",@"askVolum",@"askPrice",@"priceChange",@"priceChangePercentage",nil];
//    NSMutableDictionary *modelDic = [[NSMutableDictionary alloc]initWithObjects:objectsArray forKeys:keyArray];
//    NSLog(@"modelDic ====== %@",modelDic);
//    if(!self.quoteModelArray){
//        _quoteModelArray = [NSMutableArray arrayWithObject:modelDic];
//    }
//
//    [_quoteModelArray enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if([obj[@"instrumenID"] isEqualToString:self.instrumenID]){
//            NSArray *keys = [obj allKeys];
//            for(NSInteger i=0;i<keys.count;i++){
//                [obj setValue:objectsArray[i] forKey:keys[i]];
//            }
//            findModelIdx = idx;
//        }
//        if(idx == _quoteModelArray.count && findModelIdx != _quoteModelArray.count ){
//            [_quoteModelArray addObject:modelDic];
//        }
//    }];
//    if(self.delegate && [self.delegate respondsToSelector:@selector(reloadData)]){
//        [self.delegate reloadData];
//    }
//}


- (id)initWithArray:(NSArray*)array{
    self = [super init];
    if(self){
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
    return self;
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
