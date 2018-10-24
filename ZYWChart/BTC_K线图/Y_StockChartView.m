//
//  Y-StockChartView.m
//  BTC-Kline
//
//  Created by yate1996 on 16/4/30.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "Y_StockChartView.h"
#import "Y_KLineView.h"
#import "Masonry.h"
#import "Y_StockChartSegmentView.h"
#import "Y_StockChartGlobalVariable.h"
#import "AppDelegate.h"
#import "ICEQuote.h"
#import "UIColor+Y_StockChart.h"
@interface Y_StockChartView() <Y_StockChartSegmentViewDelegate>

/**
 *  底部选择View
 */
@property (nonatomic, strong) Y_StockChartSegmentView *segmentView;

/**
 *  图表类型
 */
@property(nonatomic,assign) Y_StockChartCenterViewType currentCenterViewType;

/**
 *  当前索引
 */
@property(nonatomic,assign,readwrite) NSInteger currentIndex;




@end


@implementation Y_StockChartView

@synthesize kLineView = _kLineView;

- (Y_KLineView *)kLineView
{
   
    if(!_kLineView)
    {
        _kLineView = [Y_KLineView new];
        [self addSubview:_kLineView];
        [_kLineView mas_makeConstraints:^(MASConstraintMaker *make) {
           // AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
//            if(appdelegate.isEable == NO){
//                //make.bottom.equalTo(self).offset(-100);
//                make.bottom.equalTo(self);
//            }
//            else{
//                make.bottom.equalTo(self);
//            }
            make.bottom.equalTo(self);
            make.right.equalTo(self);
            make.left.equalTo(self).offset(5);
            make.top.equalTo(self.segmentView.mas_bottom);
        }];
    }
    return _kLineView;
}
#pragma --mark sementView Getter 方法 懒加载
- (Y_StockChartSegmentView *)segmentView
{
    if(!_segmentView)
    {
        _segmentView = [Y_StockChartSegmentView new];
        _segmentView.delegate = self;
        [self addSubview:_segmentView];
        [_segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
           // make.bottom.left.top.equalTo(self);
            make.right.left.equalTo(self);
            AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
            if(appdelegate.isEable == YES){
                make.top.equalTo(self);
            }
            else{
                 make.top.equalTo(_quoteView.mas_bottom);
            }
            make.height.equalTo(@40);
           //make.width.equalTo(@50);
        }];
    }
    return _segmentView;
}
//实时行情信息 头部
- (void)addQuoteView{
     [[NSBundle mainBundle]loadNibNamed:@"quoteView" owner:self options:nil];
    [self addSubview:_quoteView];
    [_quoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.height.equalTo(@80);
    }];
}
#pragma --mark itemModels的setter方法
- (void)setItemModels:(NSArray *)itemModels
{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    if(appdelegate.isEable == NO){
        [self addQuoteView];
        _quoteView.backgroundColor = [UIColor whiteColor];
    }
    
    _itemModels = itemModels;
    if(itemModels)
    {
        NSMutableArray *items = [NSMutableArray array];
        for(Y_StockChartViewItemModel *item in itemModels)
        {
            [items addObject:item.title];
        }
        self.segmentView.items = items;
        Y_StockChartViewItemModel *firstModel = itemModels.firstObject;
        self.currentCenterViewType = firstModel.centerViewType;
    }
    if(self.dataSource)
    {
        AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
        if(appdelegate.isEable == YES){
            self.segmentView.selectedIndex = 6;
        }
        else{
            self.segmentView.selectedIndex = 5;
        }
    }
}

- (void)setDataSource:(id<Y_StockChartViewDataSource>)dataSource
{
    _dataSource = dataSource;
    if(self.itemModels)
    {   AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
        if(appdelegate.isEable == YES){
            self.segmentView.selectedIndex = 6;
        }
        else{
            self.segmentView.selectedIndex = 5;
        }
    }
}
- (void)reloadData
{
    self.segmentView.selectedIndex = self.segmentView.selectedIndex;
}

#pragma mark - 代理方法  按钮按下

- (void)y_StockChartSegmentView:(Y_StockChartSegmentView *)segmentView clickSegmentButtonIndex:(NSInteger)index
{

    NSLog(@"index ======= %d",index);
    self.currentIndex = index;
    //技术线
    if (index == 105) {
        
        [Y_StockChartGlobalVariable setisBOLLLine:Y_StockChartTargetLineStatusBOLL];
        self.kLineView.targetLineStatus = index;
        [self.kLineView reDraw];
        [self bringSubviewToFront:self.segmentView];
        
    }
    else  if(index >= 100 && index != 105) {
        
        [Y_StockChartGlobalVariable setisEMALine:index];
//        if(index == Y_StockChartTargetLineStatusMA)
//        {
//            [Y_StockChartGlobalVariable setisEMALine:Y_StockChartTargetLineStatusMA];
//        } else {
//            [Y_StockChartGlobalVariable setisEMALine:Y_StockChartTargetLineStatusEMA];
//        }
        self.kLineView.targetLineStatus = index;
        [self.kLineView reDraw];
        [self bringSubviewToFront:self.segmentView];
    
    }
    //主图
    else {
        //获取数据 数据源代理  也可以从订阅当中获取。     s
        if(self.dataSource && [self.dataSource respondsToSelector:@selector(stockDatasWithIndex:)])
        {
            //获得数据
            id stockData = [self.dataSource stockDatasWithIndex:index];
            if(!stockData)
            {
                return;
            }
            Y_StockChartViewItemModel *itemModel = self.itemModels[index];
            Y_StockChartCenterViewType type = itemModel.centerViewType;
            if(type != self.currentCenterViewType)
            {
                //移除当前View，设置新的View
                self.currentCenterViewType = type;
                switch (type) {
                    case Y_StockChartcenterViewTypeKline:
                    {
                       self.kLineView.hidden = NO;//显示K线图
                     //[self bringSubviewToFront:self.kLineView];
                     //[self bringSubviewToFront:self.segmentView];
                    }
                        break;
                    default:
                        break;
                }
            }
            //其它
            if(type == Y_StockChartcenterViewTypeOther)
            {
                
            }
            //type = Y_StockChartcenterViewTypeTimeLine or   Y_StockChartcenterViewTypeKLine时间线或者K线图
            else {
                NSLog(@"type ==== %d",type);
                self.kLineView.kLineModels = (NSArray *)stockData;//更改数据
                self.kLineView.MainViewType = type;
                [self.kLineView reDraw];//重绘图像
            }
            //[self bringSubviewToFront:self.segmentView];
        }
    }
}

@end

/************************ItemModel类************************/
@implementation Y_StockChartViewItemModel

+ (instancetype)itemModelWithTitle:(NSString *)title type:(Y_StockChartCenterViewType)type
{
    Y_StockChartViewItemModel *itemModel = [Y_StockChartViewItemModel new];
    itemModel.title = title;
    itemModel.centerViewType = type;
    return itemModel;
}

@end
