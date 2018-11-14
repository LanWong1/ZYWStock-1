//
//  Y-StockChartView.h
//  BTC-Kline
//
//  Created by yate1996 on 16/4/30.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Y_StockChartConstant.h"
#import "Y_KLineView.h"

//种类
typedef NS_ENUM(NSInteger, Y_KLineType) {
    KLineTypeTimeShare = 1,
    KLineType1Min,
    KLineType3MIn,
    KLineType5Min,
    KLineType10Min,
    KLineType15Min,
    KLineType30Min,
    KLineType1Hour,
    KLineType2Hour,
    KLineType4Hour,
    KLineType6Hour,
    KLineType12Hour,
    KLineType1Day,
    KLineType3Day,
    KLineType1Week
};

/**
 *  Y_StockChartView代理
 */

@protocol Y_StockChartViewDelegate <NSObject>


@end
/**
 *  Y_StockChartView数据源
 */
@protocol Y_StockChartViewDataSource <NSObject>

-(id) stockDatasWithIndex:(NSInteger)index;

@end


@interface Y_StockChartView : UIView
//最新价
@property (weak, nonatomic) IBOutlet UILabel *lastPrice;
//涨跌价格
@property (weak, nonatomic) IBOutlet UILabel *priceChange;
//涨跌百分比
@property (weak, nonatomic) IBOutlet UILabel *priceChangePercentage;


//申 卖价格
@property (weak, nonatomic) IBOutlet UILabel * AskPrice;

//申卖量
@property (weak, nonatomic) IBOutlet UILabel *AskVolume;

//申买量
@property (weak, nonatomic) IBOutlet UILabel *BidVolume;
//申买价
@property (weak, nonatomic) IBOutlet UILabel * BidPrice;

//持仓量
@property (weak, nonatomic) IBOutlet UILabel *OpenInterest;


//日增仓 (持仓 - 昨持仓)
@property (weak, nonatomic) IBOutlet UILabel *dayGrowHold;

@property (weak, nonatomic) IBOutlet UIView *quoteView;




@property (nonatomic, strong) NSArray *itemModels;

/**
 *  数据源
 */
@property (nonatomic, weak) id<Y_StockChartViewDataSource> dataSource;

/**
 *  K线图View
 */
@property (nonatomic, strong) Y_KLineView *kLineView;
/**
 *  当前选中的索引
 */
@property (nonatomic, assign,readonly) Y_KLineType currentLineTypeIndex;


-(void) reloadData;
@end

/************************ItemModel类************************/
@interface Y_StockChartViewItemModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) Y_StockChartCenterViewType centerViewType;

+ (instancetype)itemModelWithTitle:(NSString *)title type:(Y_StockChartCenterViewType)type;

@end
