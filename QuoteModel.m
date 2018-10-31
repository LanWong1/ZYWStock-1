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
@end
