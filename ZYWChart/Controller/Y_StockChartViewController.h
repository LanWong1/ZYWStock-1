//
//  YStockChartViewController.h
//  BTC-Kline
//
//  Created by yate1996 on 16/4/27.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WpQuote.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>


@interface Y_StockChartViewController : UIViewController


@property (nonatomic,copy) NSString *futu_price_step; //价格变动单位

- (instancetype)initWithScode:(NSString *)sCodeSelect;
@end
