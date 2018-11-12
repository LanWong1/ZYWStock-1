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
            quoteArrayModel.codelistDic = [[NSMutableDictionary alloc]init];
        }
    });
    return quoteArrayModel;
}


@end
