//
//  CandleCrossScreenVC.h
//  ZYWChart
//
//  Created by 张有为 on 2017/5/9.
//  Copyright © 2017年 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WpQuote.h>
#import <objc/Glacier2.h>
#import <objc/Ice.h>

@class CandleCrossScreenVC;

@protocol CandleCrossScreenVCDeleate <NSObject>

- (void)willChangeScreenMode:(CandleCrossScreenVC*)vc;

@end

@interface CandleCrossScreenVC : UIViewController

-(instancetype)initWithScode:(NSString *)sCodeSelect KlineDataList:(WpQuoteServerDayKLineList *)KlineDataList TimeData:(NSArray*)TimeData;
@property (assign, nonatomic)UIInterfaceOrientation orientation;
@property (nonatomic,weak)  id <CandleCrossScreenVCDeleate> delegate;

@end
