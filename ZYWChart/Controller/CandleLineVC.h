//
//  CandleLineVC.h
//  ZYWChart
//
//  Created by 张有为 on 2016/12/28.
//  Copyright © 2016年 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ViewController.h"
#import <WpQuote.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>

@interface CandleLineVC : UIViewController
    


//-(instancetype)initWithScode:(NSString*)sCodeSelect;
-(instancetype)initWithScode:(NSString *)sCodeSelect KlineDataList:(WpQuoteServerDayKLineList *)KlineDataList TimeData:(NSArray*)timeData;
@end
