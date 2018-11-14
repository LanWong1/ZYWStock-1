//
//  Y_StockChartLandScapeViewController.h
//  BTC-Kline
//
//  Created by zdqh on 2018/7/3.
//  Copyright © 2018 yate1996. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Y_StockChartLandScapeViewController : UIViewController

@property (nonatomic, copy) NSString* sCode;

@property (nonatomic, strong) NSArray *MinData;
@property (nonatomic, strong) NSArray *fiveMinsData;
@property (nonatomic, strong) NSArray *fifteenMinsData;
@property (nonatomic, strong) NSArray *weekData;
@property (nonatomic, strong) NSArray *dayData;
@property (nonatomic, strong) NSArray *monthData;

@end
