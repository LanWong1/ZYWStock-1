//
//  YStockChartViewController.m
//  BTC-Kline
//
//  Created by yate1996 on 16/4/27.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "Y_StockChartViewController.h"
#import "Masonry.h"
#import "Y_StockChartView.h"
#import "Y_StockChartView.h"
#import "Y_KLineGroupModel.h"
#import "UIColor+Y_StockChart.h"
#import "AppDelegate.h"
#import "Y_StockChartLandScapeViewController.h"
#import "ICEQuote.h"
#import "ICEQuickOrder.h"
#import <AudioToolbox/AudioToolbox.h>
#import "checkVC.h"
#import "NSArray+Extension.h"
#import "NSDictionary+Extension.h"
#import "QuoteArrayModel.h"
#import "QuoteModel.h"



typedef NS_ENUM(NSInteger,TradeKind){
    TradeKindeBuyIn       = 0,//看涨
    TradeKindeSellOut     = 1,  //看跌
    TradeKindClearAll     = 2,
    TradeKindClearFenPi   = 3,
    TradeKindRollBackRise = 4,//看涨反向开仓
    TradeKindRollBackDown = 5,  //看跌反向开仓
    TradeKindChasingRise  = 6,//看涨追单
    TradeKindChasingDown  = 7,//看跌
};



#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_MAX_LENGTH MAX(kScreenWidth,kScreenHeight)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

@interface Y_StockChartViewController ()<Y_StockChartViewDataSource,UIGestureRecognizerDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,QuoteArrayModelDelegate>

@property (nonatomic, strong) Y_StockChartLandScapeViewController *stockChartLangVC;
@property (nonatomic, strong) Y_StockChartView *stockChartView;
@property (nonatomic, strong) Y_KLineGroupModel *groupModel;
@property (nonatomic, copy) NSMutableDictionary <NSString*, Y_KLineGroupModel*> *modelsDict;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString* sCode;
@property (nonatomic, copy) WpQuoteServerDayKLineList* KlineData;
@property (nonatomic,strong) UIView *tradeButtonView;
@property (nonatomic,strong) NSString *buyCount;//下单手数
@property (nonatomic,copy) NSString *loseLimit;//止损单价变动
@property (nonatomic,copy) NSString *winLimit;//止盈单价变动
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic,strong) UIView *tradeView ;
@property (nonatomic,assign)NSInteger tradeButtonOldFlagChangeFlag;

//线的数据
@property (nonatomic, strong) NSMutableArray *MinData;
@property (nonatomic, strong) NSMutableArray *fiveMinsData;
@property (nonatomic, strong) NSMutableArray *fifteenMinsData;
@property (nonatomic, strong) NSMutableArray *weekData;
@property (nonatomic, strong) NSMutableArray *dayData;
@property (nonatomic, strong) NSMutableArray *monthData;


//交易按钮 看涨 清仓 分批清仓 看跌
@property (strong,nonatomic) UIButton *riseButton;
@property (strong,nonatomic) UIButton *dropButton;
@property (strong,nonatomic) UIButton *clearButton;
@property (strong,nonatomic) UIButton *clearEachButton;

//止盈止损picker
@property (strong,nonatomic) UIPickerView *lossLimitPicker;
@property (strong,nonatomic) UIPickerView *winLimitPicker;


//总权益
@property (strong,nonatomic) UILabel *totalEquityLable;
//保证金
@property (strong,nonatomic) UILabel *cashDepositLable;
//可用资金
@property (strong,nonatomic) UILabel *availableCapitalLable;

//总权益 保证金 可用资金数字
@property (assign,nonatomic) NSInteger totalEquityNumber;
@property (assign,nonatomic) NSInteger cashDepositNumber;
@property (assign,nonatomic) NSInteger availableCapitalNumber;

//下单次数
@property (assign,nonatomic) NSInteger OrderCount;
//持仓数量
@property (assign,nonatomic)  NSInteger buyCountValue;
//持仓手数的 array
@property (nonatomic, strong) NSMutableArray *buyCountArray;
//交易记录 (手数 均价) 记录每笔交易的手数和均价
@property (nonatomic, strong) NSMutableArray *tradeRecordArray;

@property (nonatomic, strong) NSTimer *refreshTimer;

//持仓方向
@property (weak, nonatomic) IBOutlet   UILabel *holdDirectLable;
//持仓数量
@property (weak, nonatomic) IBOutlet UILabel *holdCountLable;
//持仓均价
@property (weak, nonatomic) IBOutlet UILabel *holdAverageLable;
//持仓盈亏
@property (weak, nonatomic) IBOutlet UILabel *holdWinLossLable;



//持仓情况view
@property (weak, nonatomic) IBOutlet   UIView *lableView;
//交易设置 view
@property (weak, nonatomic) IBOutlet   UIView *tradeSetView;
//止盈止损 输入
@property (weak, nonatomic) IBOutlet UITextField *loseLimtedTextField;
@property (weak, nonatomic) IBOutlet UITextField *winLimitedTextField;

@property (strong,nonatomic) UIView *buttomBtnView;

@property (strong,nonatomic) UIScrollView *scrollView;

@property (nonatomic, assign) NSInteger tradeKind;


@property (nonatomic,strong)  NSMutableArray<__kindof QuoteModel*> *quoteModelArray;
@property (nonatomic,strong) QuoteArrayModel* quoteArrayModel;
@end

@implementation Y_StockChartViewController




#pragma --mark icetool delegate 用于传值 更新数据
//从icequote中获取数据 更新图像
//- (void)refreshTimeline:(NSString *)s{
//    NSLog(@"delegate.........%@",s);
//    /*
//     Y_StockChartViewItemModel *itemModel = self.itemModels[index];
//     Y_StockChartCenterViewType type = itemModel.centerViewType;
//     self.kLineView.kLineModels = (NSArray *)stockData;//新的数据
//     self.kLineView.MainViewType = type;
//     [self.kLineView reDraw];//重绘图像
//     */
//    //可从这里传入新的数据 然后重绘数据
//}
//
//
//-(void)refrenshTest:(NSString *)s{
//    NSLog(@"aaaa     %@",s);
//}


#pragma --mark 系统初始化函数
- (instancetype)initWithScode:(NSString *)sCodeSelect{
    self = [super init];
    
    if(self){
        _sCode = sCodeSelect;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self subscibe];
  
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//设置返回字体颜色
    self.navigationController.navigationBar.barTintColor = DropColor;//导航栏背景色
    self.navigationController.navigationBar.translucent =YES;
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};//设置标题文字为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;//设置状态时间文字为白色
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self unSubscibe];
    if(_refreshTimer != nil){
        NSLog(@"关闭定时器");
        [_refreshTimer invalidate];
        _refreshTimer = nil;
    }
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor blackColor]};
   
}

- (void)viewDidLoad {
 
    [super viewDidLoad];

    _buyCountArray = [NSMutableArray array];
    _tradeRecordArray = [NSMutableArray array];
    //
    _quoteArrayModel = [QuoteArrayModel shareInstance];
    _quoteArrayModel.delegate = self;
    _quoteModelArray = [NSMutableArray array];
    
    _MinData = [NSMutableArray array];
    _fiveMinsData = [NSMutableArray array];
    _fifteenMinsData = [NSMutableArray array];
    _monthData = [NSMutableArray array];
    _weekData = [NSMutableArray array];
    _dayData = [NSMutableArray array];
    
    [self downLoadData];//下载数据
    
    self.navigationItem.title = self.title;
    self.view.backgroundColor = [UIColor backgroundColor];
    [self addScrollView];//上下滑动
    
    
    self.stockChartView.backgroundColor = [UIColor backgroundColor];//调用了getter方法
    self.currentIndex = -1;
    [self addBottomBtnView];
    [self itemModels];//加载数据
  
    
    
    
    //[self subscibe];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];//键盘将要隐藏通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];//键盘将要显示
    //交易成功通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tradeResult:) name:@"tradeNotify" object:nil];
    //行情推送通知
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(quoteData:) name:@"quoteNotity" object:nil];
}



#pragma mark  通知中心
//交易成功返回消息
- (void)tradeResult:(NSNotification*)notify{
    
    NSLog(@"交易结果========%@",notify.userInfo[@"message"]);
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 150, 650, 30)];
    //NSLog(@"message array =  %@",[notify.userInfo[@"message"] componentsSeparatedByString:@" "]);
    NSArray *messageArray = [[NSArray alloc]initWithArray:[notify.userInfo[@"message"] componentsSeparatedByString:@" "]];
    //交易成功
    if([messageArray[2] isEqualToString:@"成交完毕"]){
        NSLog(@"交易类型 = ==== %ld",(long)_tradeKind);
        switch (_tradeKind) {
            case TradeKindeBuyIn:
                //下单成功
                _holdDirectLable.text = @"多";     //看涨按钮按下 持仓就为多
                [_holdDirectLable setTextColor:RoseColor];
                
                [_riseButton setTitle:@"追单" forState:UIControlStateNormal];
                [_dropButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                //NSLog(@"看涨下单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
                [_buyCountArray addObject:@([_buyCount integerValue])];
                _buyCountValue += [_buyCount integerValue];//手数
                _OrderCount += 1;//交易次数
                break;
            case TradeKindRollBackRise:
                [_tradeRecordArray removeAllObjects];
                _holdDirectLable.text = @"多";     //看涨按钮按下 持仓就为多
                [_holdDirectLable setTextColor:RoseColor];
                //反向开仓 重新计数 清空现在的数据
                _buyCountValue = 0;
                _OrderCount = 0;
                [_buyCountArray removeAllObjects];//清空 array
                [_riseButton setTitle:@"追单" forState:UIControlStateNormal];
                [_dropButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                //NSLog(@"看涨反向开仓:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
                [_buyCountArray addObject:@([_buyCount integerValue])];
                _buyCountValue += [_buyCount integerValue];
                _OrderCount += 1;
                break;
            case TradeKindChasingRise:
                _holdDirectLable.text = @"多";     //看涨按钮按下 持仓就为多
                [_holdDirectLable setTextColor:RoseColor];
                [_buyCountArray addObject:@([_buyCount integerValue])];
                _buyCountValue += [_buyCount integerValue];
                _OrderCount += 1;
                break;
            case TradeKindeSellOut:
                _holdDirectLable.text = @"空";//看跌按钮按下 持仓就为多
                [_holdDirectLable setTextColor:DropColor];
                [_dropButton setTitle:@"追单" forState:UIControlStateNormal];
                [_riseButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                // NSLog(@"看跌下单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
                _buyCountValue += [_buyCount integerValue];
                [_buyCountArray addObject:@([_buyCount integerValue])];
                _OrderCount += 1;
                break;
            case TradeKindRollBackDown:
                [_tradeRecordArray removeAllObjects];
                _holdDirectLable.text = @"空";//看跌按钮按下 持仓就为多
                [_holdDirectLable setTextColor:DropColor];
                //反向开仓 重新计数 清空现在的数据
                _buyCountValue = 0;
                _OrderCount = 0;
                [_buyCountArray removeAllObjects];
                [_dropButton setTitle:@"追单" forState:UIControlStateNormal];
                [_riseButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                //NSLog(@"看跌反向开仓:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
                [_buyCountArray addObject:@([_buyCount integerValue])];
                _buyCountValue += [_buyCount integerValue];
                _OrderCount += 1;
                break;
            case TradeKindChasingDown:
                _holdDirectLable.text = @"空";//看跌按钮按下 持仓就为多
                [_holdDirectLable setTextColor:DropColor];
                [_buyCountArray addObject:@([_buyCount integerValue])];
                _buyCountValue += [_buyCount integerValue];
                _OrderCount += 1;
                break;
            case TradeKindClearAll:
                //清仓成功 在返回消息处更改
                _OrderCount     = 0;
                _buyCountValue  = 0;
                [_buyCountArray removeAllObjects];
                _holdDirectLable.text = @"--";
                [_holdDirectLable setTextColor:[UIColor yellowColor]];
                [_dropButton setTitle:@"看跌" forState:UIControlStateNormal];
                [_riseButton setTitle:@"看涨" forState:UIControlStateNormal];
                break;
            case TradeKindClearFenPi:
                if(_OrderCount>0){
                    _buyCountValue -= [[_buyCountArray lastObject] integerValue];
                    [_buyCountArray removeLastObject];
                    _OrderCount -= 1;
                    if(_OrderCount == 0){
                        _holdDirectLable.text = @"--";
                        [_dropButton setTitle:@"看跌" forState:UIControlStateNormal];
                        [_riseButton setTitle:@"看涨" forState:UIControlStateNormal];
                    }
                }
                break;
            default:
                break;
        }
        _holdCountLable.text = [NSString stringWithFormat:@"%ld%@",(long)_buyCountValue,@"手"];
        
        
        if([messageArray[1] containsString:@"开仓"]){
            NSLog(@"求均价==================");
            //每笔交易的手数和价格
            
            NSString *avergePrice = [messageArray[3] componentsSeparatedByString:@"="][1];
            NSArray *objectArr = [NSArray arrayWithObjects:_buyCount,avergePrice,nil ];
            NSArray *keytArr = [NSArray arrayWithObjects:@"count",@"avgPrice",nil ];
            NSDictionary *eachTradeInfo = [[NSDictionary alloc]initWithObjects:objectArr forKeys:keytArr];
//            [eachTradeInfo setValue:_buyCount  forKey:@"count"];
//            [eachTradeInfo setValue:avergePrice forKey:@"avgPrice"];
            
            
            
            NSLog(@"eachtradeInfo == %@",eachTradeInfo);
            
            
            
            [_tradeRecordArray addObject:eachTradeInfo];

            __block NSInteger count;
            __block float allHold;
            [_tradeRecordArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                count += [obj[@"count"] integerValue];
                allHold += [obj[@"count"] integerValue] * [obj[@"avgPrice"] floatValue];
            }];
            NSString *avgPrice = [NSString stringWithFormat:@"%.1f",allHold/count];
            NSLog(@"均价 === %@", avgPrice);
            _holdAverageLable.text = avgPrice; //均价
        }
    }


    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  // 震动
    AudioServicesPlaySystemSound(1007);//声音提示
    lable.text = notify.userInfo[@"message"];
    lable.textColor = [UIColor redColor];
    lable.font = [UIFont systemFontOfSize:15];
    lable.textAlignment = NSTextAlignmentLeft;
    lable.backgroundColor = [UIColor clearColor];
    [_stockChartView addSubview:lable];
    [UIView animateWithDuration:10 animations:^{
        [lable setFrame:CGRectMake(lable.frame.origin.x - 650, 150, 650, 30)];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"lable disappear");
        [lable removeFromSuperview];
    });
}


- (void)quoteViewRefresh:(NSMutableArray *)array{
    [_quoteModelArray addObjectsFromArray:array];
    
    [_quoteModelArray enumerateObjectsUsingBlock:^(__kindof QuoteModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:0 error:NULL];
        NSString *code = [regular stringByReplacingMatchesInString:obj.instrumenID options:0 range:NSMakeRange(0, [obj.instrumenID length]) withTemplate:@""];
        if( [self.title containsString: code]){
            //价格变化
            _stockChartView.lastPrice.text = obj.lastPrice;
            _stockChartView.priceChangePercentage.text = obj.priceChangePercentage;
            _stockChartView.priceChange.text =  obj.priceChange;
            _stockChartView.priceChangePercentage.textColor = RoseColor;
            _stockChartView.priceChange.textColor = RoseColor;
            _stockChartView.lastPrice.textColor = RoseColor;
            
            if([_stockChartView.priceChange.text containsString:@"-"]){
                _stockChartView.priceChangePercentage.textColor = DropColor;
                _stockChartView.priceChange.textColor = DropColor;
                _stockChartView.lastPrice.textColor = DropColor;
                
             
            }
       
            
            _stockChartView.AskPrice.text = obj.askPrice;
            _stockChartView.AskVolume.text = obj.askVolum;
            _stockChartView.BidPrice.text = obj.bidPrice;
            _stockChartView.BidVolume.text = obj.bidVolum;
            _stockChartView.OpenInterest.text = obj.openInterest;

            _stockChartView.dayGrowHold.text = obj.openInterestChange;//持仓增量
            //有持仓
            if(_buyCountValue>0){
                //持仓盈亏
                __block float win;
                [_tradeRecordArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    win += [obj[@"count"] integerValue] * ([_stockChartView.lastPrice.text floatValue]- [obj[@"avgPrice"] floatValue]);
                    
                }];
                if (win<0) {
                    _holdWinLossLable.text = [NSString stringWithFormat:@"%@%.1f",@"-",win];
                    [_holdWinLossLable setTextColor:DropColor];
                }
                else{
                    _holdWinLossLable.text = [NSString stringWithFormat:@"%.1f",win];
                    [_holdWinLossLable setTextColor:RoseColor];
                }
            }
            
        }
        
    }];
}

////行情通知
//- (void)quoteData:(NSNotification*)notif{
//
//
//    NSArray *arry = [NSArray arrayWithArray:notif.userInfo[@"message"]];
//   //删除字符串的数字
//    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:0 error:NULL];
//    NSString *code = [regular stringByReplacingMatchesInString:arry[1] options:0 range:NSMakeRange(0, [arry[1] length]) withTemplate:@""];
//
//
//    NSLog(@"code is ......... %@, code lenth === %lu",code,(unsigned long)[code length]);
//
//    //NSLog(@"行情========%@   type = %@",notif.userInfo[@"message"],notif.userInfo[@"type"]);
//    if( [self.title containsString: code]){
//
//        //价格变化
//        _stockChartView.lastPrice.text = arry[4];
//        float priceChange = [arry[4] floatValue] - [ arry[5] floatValue];
//        //价格变化百分比
//        float chagepercentage = 100*priceChange/[arry[5] floatValue];
//        //NSLog(@"chagepercentage ===  %f",chagepercentage);
//
//        if(priceChange<0){
//            self.stockChartView.priceChangePercentage.textColor = DropColor;//导航栏背景色
//            _stockChartView.priceChange.textColor = DropColor;
//            _stockChartView.lastPrice.textColor = DropColor;
//            _stockChartView.priceChangePercentage.text = [NSString stringWithFormat:@"%.2f%@",chagepercentage ,@"\%"];
//            _stockChartView.priceChange.text =  [NSString stringWithFormat:@"%.1f",priceChange];
//        }
//        else{
//
//            _stockChartView.priceChangePercentage.text = [NSString stringWithFormat:@"%@%.2f%@",@"+",chagepercentage ,@"\%"];
//            _stockChartView.priceChange.text =  [NSString stringWithFormat:@"%@%.1f",@"+",priceChange];
//            self.stockChartView.priceChangePercentage.textColor = RoseColor;//导航栏背景色
//            _stockChartView.priceChange.textColor = RoseColor;
//            _stockChartView.lastPrice.textColor = RoseColor;
//
//        }
//
//        _stockChartView.AskPrice.text = arry[24];
//        _stockChartView.AskVolume.text = arry[25];
//        _stockChartView.BidPrice.text = arry[22];
//        _stockChartView.BidVolume.text = arry[23];
//        _stockChartView.OpenInterest.text = arry[13];
//        NSInteger InterestAdd = [arry[13] integerValue] - [arry[7] integerValue];
//        _stockChartView.dayGrowHold.text = [NSString stringWithFormat:@"%ld",(long)InterestAdd];
//        //有持仓
//        if(_buyCountValue>0){
//            //持仓盈亏
//            __block float win;
//            [_tradeRecordArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                win += [obj[@"count"] integerValue] * ([arry[4] floatValue]- [obj[@"avgPrice"] floatValue]);
//
//            }];
//            if (win<0) {
//                _holdWinLossLable.text = [NSString stringWithFormat:@"%@%.1f",@"-",win];
//                [_holdWinLossLable setTextColor:DropColor];
//            }
//            else{
//                _holdWinLossLable.text = [NSString stringWithFormat:@"%.1f",win];
//                [_holdWinLossLable setTextColor:RoseColor];
//            }
//        }
//
//    }
//}
#pragma --mark 添加views
// scrollview
- (void)addScrollView{
    _scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    _scrollView.scrollEnabled = YES;
    _scrollView.userInteractionEnabled = YES;
}


//底部交易和查询按钮
- (void)addBottomBtnView{
    
    self.buttomBtnView = [[UIView alloc]init];
    _buttomBtnView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_buttomBtnView];
    
    
    [_buttomBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.top.equalTo(_stockChartView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@60);
    }];
    UIButton *tradeBtn = [[UIButton alloc]init];
    tradeBtn.backgroundColor = RoseColor;

    tradeBtn.tag = 200;
    [tradeBtn setTitle:@"交易" forState:UIControlStateNormal];
    [tradeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [tradeBtn addTarget: self action:@selector(bottomBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
    [_buttomBtnView addSubview:tradeBtn];
    [tradeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_buttomBtnView);
        make.width.equalTo(@ (DEVICE_WIDTH/2));
        make.bottom.equalTo(_buttomBtnView.mas_bottom);
        make.top.equalTo(_buttomBtnView.mas_top);
    }];
    
    UIButton *checkBtn = [[UIButton alloc]init];
    checkBtn.backgroundColor = DropColor;
    checkBtn.tag = 201;
    [checkBtn setTitle:@"查询" forState:UIControlStateNormal];
    [checkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [checkBtn addTarget: self action:@selector(bottomBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
    [_buttomBtnView addSubview:checkBtn];
    [checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_buttomBtnView);
        make.width.equalTo(@ (DEVICE_WIDTH/2));
        make.bottom.equalTo(_buttomBtnView.mas_bottom);
        make.top.equalTo(_buttomBtnView.mas_top);
    }];
    
}
// 交易 筹码 止损止盈
- (void)addXibViews{

    [_tradeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(self.view);
        //make.top.equalTo(self.stockChartView.mas_bottom);
        make.height.equalTo(@(DEVICE_HEIGHT/2));
        make.bottom.equalTo(self.view.mas_bottom);
    }];

    
    [[NSBundle mainBundle]loadNibNamed:@"buttonView" owner:self options:nil];
    [self.tradeView addSubview:_lableView];
    [_lableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tradeView.mas_left);
        make.width.equalTo(self.tradeView);
        make.top.equalTo(self.tradeView.mas_top).offset(10);
        make.height.equalTo(@80);
        //make.top.equalTo(_tradeSetView.mas_bottom);
    }];
    
    [self.tradeView addSubview:_tradeSetView];
    _tradeSetView.backgroundColor = [UIColor clearColor];
    [_tradeSetView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.top.equalTo(self.stockChartView.mas_bottom).offset(100);
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(self.view);
        make.height.equalTo(@150);
        make.top.equalTo(_lableView.mas_bottom).offset(10);
    }];
    
    _loseLimtedTextField.textColor = [UIColor whiteColor];
    _winLimitedTextField.textColor = [UIColor whiteColor];
    _loseLimtedTextField.text = @"0";
    _winLimitedTextField.text = @"0";
    _loseLimtedTextField.backgroundColor = DropColor;
    _winLimitedTextField.backgroundColor = RoseColor;
    [self addLimitPicker];
}

//止损止盈picker 滚盘
- (void)addLimitPicker{
    _lossLimitPicker = [[UIPickerView alloc]init];
    //止损
    [_tradeSetView addSubview:_lossLimitPicker];
   
    [_lossLimitPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(120);
        make.width.equalTo(@40);
        //make.bottom.equalTo(_tradeSetView.mas_bottom).offset(-18);
        make.height.equalTo(@80);
        make.centerY.equalTo(_loseLimtedTextField.mas_centerY);
    }];
    _lossLimitPicker.tag = 1000;
    _lossLimitPicker.delegate = self;
    _lossLimitPicker.dataSource = self;
    //止盈
     _winLimitPicker  = [[UIPickerView alloc]init];
     [_tradeSetView addSubview:_winLimitPicker];
    [_winLimitPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-120);
        make.width.equalTo(@40);
        //make.bottom.equalTo(_tradeSetView.mas_bottom).offset(-18);
        make.height.equalTo(@80);
        make.centerY.equalTo(_winLimitedTextField.mas_centerY);

    }];
    _winLimitPicker.dataSource = self;
    _winLimitPicker.delegate = self;
    _winLimitPicker.tag = 1001;
}
// 交易按钮 看涨 看跌 清仓 分批清仓
-(void)addTradeButtons{
    UIView *tradeButtonView = [[UIView alloc]init];
    [tradeButtonView setUserInteractionEnabled:YES];
    [self.tradeView addSubview:tradeButtonView];
    
    [tradeButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.height.equalTo(@70);
        make.width.equalTo(self.view);
        if(IS_IPHONE_X){
            make.bottom.equalTo(self.tradeView.mas_bottom).offset(-34);
        }
        else{
            make.bottom.equalTo(self.view);
        }
    }];

    //看涨按键
    _riseButton = [[UIButton alloc]init];
    [_riseButton setTitle:@"看涨" forState:UIControlStateNormal];
    [_riseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_riseButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _riseButton.backgroundColor = RoseColor;
    _riseButton.layer.cornerRadius = 35;
    _riseButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [tradeButtonView addSubview:_riseButton];
    
    [_riseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(tradeButtonView.mas_bottom);
        make.left.equalTo(tradeButtonView.mas_left).offset(30);
        make.width.equalTo(@70);
        make.height.equalTo(@70);
    }];
    
    
    //看跌按键
    _dropButton = [[UIButton alloc]init];
    [_dropButton setTitle:@"看跌" forState:UIControlStateNormal];
    [_dropButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_dropButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _dropButton.backgroundColor = DropColor;
    _dropButton.titleLabel.font = [UIFont systemFontOfSize:16];
    _dropButton.layer.cornerRadius = 35;
    [tradeButtonView addSubview:_dropButton];
    [_dropButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(tradeButtonView.mas_bottom);
        make.right.equalTo(tradeButtonView.mas_right).offset(-30);
        make.width.equalTo(@70);
        make.height.equalTo(@70);
    }];
    
    
    
    //清仓按键
    //_clearButton = [[UIButton alloc]initWithFrame:CGRectMake(130, self.view.frame.size.height - 70, 70, 70)];
    //_clearButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    _clearButton = [[UIButton alloc]init];
    [_clearButton setTitle:@"清\n仓" forState:UIControlStateNormal];
    [_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _clearButton.backgroundColor = [UIColor blueColor];
    _clearButton.titleLabel.numberOfLines = 2;
     _clearButton.titleLabel.font = [UIFont systemFontOfSize:16];
  // [self.view addSubview:_clearButton];
    [tradeButtonView addSubview:_clearButton];
    [_clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(tradeButtonView.mas_bottom);
        if(IS_IPHONE_X){
            make.right.equalTo(tradeButtonView.mas_left).offset(185);
        }
        else{
           make.right.equalTo(tradeButtonView.mas_left).offset(205);
        }
        make.width.equalTo(@70);
        make.height.equalTo(@70);
    }];
    

    //分批清仓
    //_clearEachButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 200, self.view.frame.size.height - 70, 70, 70)];
    _clearEachButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    [_clearEachButton setTitle:@"分批\n清仓" forState:UIControlStateNormal];
    [_clearEachButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_clearEachButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _clearEachButton.backgroundColor = [UIColor orangeColor];
    _clearEachButton.titleLabel.numberOfLines = 2;
    _clearEachButton.titleLabel.font = [UIFont systemFontOfSize:16];
    //[self.view addSubview:_clearEachButton];
    [tradeButtonView addSubview:_clearEachButton];
    [_clearEachButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(tradeButtonView.mas_bottom);
        if(IS_IPHONE_X){
            make.left.equalTo(tradeButtonView.mas_right).offset(-185);
        }
        else{
            make.left.equalTo(tradeButtonView.mas_right).offset(-205);
        }
        make.left.equalTo(tradeButtonView.mas_right).offset(-185);
        make.width.equalTo(@70);
        make.height.equalTo(@70);
    }];
    
    [tradeButtonView layoutIfNeeded];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_clearButton.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(_clearButton.frame.size.height/2,_clearButton.frame.size.height/2)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _clearButton.bounds;
    maskLayer.path = maskPath.CGPath;
    _clearButton.layer.mask = maskLayer;
    
    
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:_clearEachButton.bounds byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight) cornerRadii:CGSizeMake(_clearEachButton.frame.size.height/2,_clearButton.frame.size.height/2)];//圆角大小
    CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
    maskLayer1.frame = _clearEachButton.bounds;
    maskLayer1.path = maskPath1.CGPath;
    _clearEachButton.layer.mask = maskLayer1;
    
    
    
    [_riseButton addTarget:self action:@selector(tradeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_dropButton addTarget:self action:@selector(tradeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_clearButton addTarget:self action:@selector(tradeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
     [_clearEachButton addTarget:self action:@selector(tradeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    //_clearButton = [[UIButton alloc]init];
    _dropButton.tag      = 501;
    _riseButton.tag      = 500;
    _clearButton.tag     = 502;
    _clearEachButton.tag = 503;
    

    
}
//保证金 总权益 可用资金
-(void)addCountView{
    
    _totalEquityLable = [[UILabel alloc]init];
    _totalEquityLable.text = [NSString stringWithFormat:@"%@%ld",@"总权益:",(long)_totalEquityNumber];
    _totalEquityLable.textAlignment = NSTextAlignmentCenter;
    _totalEquityLable.backgroundColor = [UIColor clearColor];
    _totalEquityLable.textColor = [UIColor whiteColor];
    _totalEquityLable.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_totalEquityLable];
    [_totalEquityLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_riseButton);
        make.right.equalTo(_riseButton);
        make.bottom.equalTo(_riseButton.mas_top);
    }];
    
    _cashDepositLable = [[UILabel alloc]init];
    _cashDepositLable.text = [NSString stringWithFormat:@"%@%ld",@"保证金:",(long)_cashDepositNumber];
    _cashDepositLable.textAlignment = NSTextAlignmentCenter;
    _cashDepositLable.backgroundColor = [UIColor clearColor];
    _cashDepositLable.textColor = [UIColor whiteColor];
    _cashDepositLable.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_cashDepositLable];
    [_cashDepositLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_clearButton.mas_left).offset(10);
        make.right.equalTo(_clearEachButton.mas_right);
        make.bottom.equalTo(_clearButton.mas_top);
    }];
    
    _availableCapitalLable = [[UILabel alloc]init];
    _availableCapitalLable.text = [NSString stringWithFormat:@"%@%ld",@"可用资金:",(long)_availableCapitalLable];
    _availableCapitalLable.textAlignment = NSTextAlignmentCenter;
    _availableCapitalLable.backgroundColor = [UIColor clearColor];
    _availableCapitalLable.textColor = [UIColor whiteColor];
    _availableCapitalLable.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_availableCapitalLable];
    [_availableCapitalLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_dropButton.mas_left);
        make.right.equalTo(_dropButton.mas_right);
        make.bottom.equalTo(_dropButton.mas_top);
    }];
    
}
#pragma --mark 按键相关

-(void)bottomBtnPressed:(UIButton *)btn{
    //交易
    if(btn.tag == 200){
        
        if(!_tradeView){
            
            _tradeView = [[UIView alloc]init];
            _tradeView.backgroundColor = [UIColor whiteColor];
            UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tradeViewDown)];
            swipe.direction = UISwipeGestureRecognizerDirectionDown;
            
            [_tradeView addGestureRecognizer:swipe];
            
            [self.view addSubview:_tradeView];
            [self addTradeButtons];
            [self addXibViews];
        }
        _tradeView.hidden = NO;
        self.buttomBtnView.hidden = YES;
    }
    else{
        checkVC *vc = [checkVC new];
        vc.hidesBottomBarWhenPushed = YES;
        // [self presentViewController:vc animated:YES completion:nil];
        //UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
- (void)tradeViewDown{
    if(_buttomBtnView.hidden == YES && _tradeView.hidden == NO){
        NSLog(@"tradeView t隐藏了");
        _tradeButtonOldFlagChangeFlag = 1;
        _tradeView.hidden = YES;
        _buttomBtnView.hidden = NO;
    }
}
//长按手势
- (IBAction)longPress1:(UILongPressGestureRecognizer *)gustureRecogonizeer {
    NSLog(@"长恩触发");
    if (gustureRecogonizeer.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    UIButton *btn = (UIButton*)(gustureRecogonizeer.view);
    NSLog(@"%ld",btn.tag);
    [self editChip:btn];
}

//弹窗输入 设置筹码按钮 chip 筹码的意思
- (void)editChip:(UIButton*)btn{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请输入数字" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"cancel");
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [btn setTitle:alertController.textFields.firstObject.text forState:UIControlStateNormal];
        NSLog(@"OK  === %@",alertController.textFields.firstObject.text);
        [alertController.textFields.firstObject resignFirstResponder];//隐藏键盘
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入数字";
        textField.keyboardType = UIKeyboardTypeNumberPad ;
        textField.keyboardAppearance = UIKeyboardAppearanceDark;
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

//下单键按下
-(void)tradeBtnPressed:(UIButton*)sender{
    
    
    ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
    
//    _tradeView.hidden = YES;
//    _buttomBtnView.hidden = NO;
//
    if (sender.tag == 500 || sender.tag  == 501) {
   
//        if([_winLimitedTextField.text  isEqual: @""]||[_loseLimtedTextField.text  isEqual: @""]){
//            
//            
//            
////            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"输入止损止盈" preferredStyle:UIAlertControllerStyleAlert];
////            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
////            [self presentViewController:alert animated:YES completion:nil];
//        }
        //委托手数判断
        if([_buyCount integerValue] == 0){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"委托手数不能为零" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        //看涨
        else if(sender.tag == 500){
           //看涨
            if([sender.titleLabel.text isEqualToString:@"看涨"]){
                int ret = 0;
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
                NSString *strCmd = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",quickOrder.strPassword,@"=",_buyCount,@"=",@"1",@"=",_loseLimtedTextField.text,@"=",_winLimitedTextField.text,@"=",@"1",@"=",@"0",@"=",@"0"];
                @try{
                    //看涨
                    self.tradeKind = TradeKindeBuyIn;
                    ret = [quickOrder.quickOrder SendOrder:@"InsertOrder" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
                    
                }
                @catch(NSException *s){
                    ret = -1;
                    [strErroInfo appendString: @"下单失败,请检查网络连接"];
                }
                if(ret < 0 ){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:strErroInfo preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
//                else{
//                    //下单成功
////                    _holdDirectLable.text = @"多";     //看涨按钮按下 持仓就为多
////                    [_holdDirectLable setTextColor:RoseColor];
////
////                    [_riseButton setTitle:@"追单" forState:UIControlStateNormal];
////                    [_dropButton setTitle:@"反向开仓" forState:UIControlStateNormal];
////                    //NSLog(@"看涨下单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
////                    [_buyCountArray addObject:@([_buyCount integerValue])];
////                    _buyCountValue += [_buyCount integerValue];//手数
////                    _OrderCount += 1;//交易次数
//                }
            }
            //反向开仓
            else if ([sender.titleLabel.text isEqualToString:@"反向开仓"]){
                int ret = 0;
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
                //NSString *strCmd = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",quickOrder.strPassword,@"=",@"-1",@"=",@"1",@"=",_loseLimtedTextField.text,@"=",_winLimitedTextField.text,@"=",@"99",@"=",@"0",@"=",@"0"];
               
                @try{
                    _tradeKind = TradeKindRollBackRise;//看涨反向开仓
                    
                   // ret = [quickOrder.quickOrder SendOrder:@"InsertOrder" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
                    NSLog(@"_buycountvalue = %ld",_buyCountValue);
                    //ret = [quickOrder.quickOrder SendOrder:@"RollBackOrder" strCmd:[NSString stringWithFormat:@"%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",@"-1"] strOut:&strOut strErrInfo:&strErroInfo];
                    
                     ret = [quickOrder.quickOrder SendOrder:@"RollBackOrder" strCmd:[NSString stringWithFormat:@"%@%@%@%@%ld",quickOrder.strFunAcc,@"=",self.sCode,@"=",_buyCountValue] strOut:&strOut strErrInfo:&strErroInfo];
                    
                    NSLog(@"看涨反向开仓 strcmd == %@ strout = %@ erro = %@",[NSString stringWithFormat:@"%@%@%@%@%ld",quickOrder.strFunAcc,@"=",self.sCode,@"=",(long)_buyCountValue],strOut,strErroInfo);
                    
                 
                }
                @catch(NSException *s){
                    ret = -1;
                    [strErroInfo appendString: @"下单失败,请检查网络连接"];
                }
                
                
                if(ret < 0 ){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:strErroInfo preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
//                else{
////                    _holdDirectLable.text = @"多";     //看涨按钮按下 持仓就为多
////                    [_holdDirectLable setTextColor:RoseColor];
////                    //反向开仓 重新计数 清空现在的数据
////                    _buyCountValue = 0;
////                    _OrderCount = 0;
////                    [_buyCountArray removeAllObjects];//清空 array
////                    [_riseButton setTitle:@"追单" forState:UIControlStateNormal];
////                    [_dropButton setTitle:@"反向开仓" forState:UIControlStateNormal];
////                    //NSLog(@"看涨反向开仓:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
////                    [_buyCountArray addObject:@([_buyCount integerValue])];
////                    _buyCountValue += [_buyCount integerValue];
////                    _OrderCount += 1;
//                }
            }
            //追单
            else{
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
                int ret = 0;
                @try{
                    
                    NSString *strCmd = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",quickOrder.strPassword,@"=",_buyCount,@"=",@"1",@"=",_loseLimtedTextField.text,@"=",_winLimitedTextField.text,@"=",@"1",@"=",@"0",@"=",@"0"];
                    
                    ret = [quickOrder.quickOrder SendOrder:@"InsertOrder" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
                    
                    NSLog(@"看涨追单结果=====%@  erro ==== %@",strOut,strErroInfo);
                }
                @catch(NSException *s){
                    ret = -1;
                    [strErroInfo appendString: @"下单失败,请检查网络连接"];
                }
                if(ret < 0 ){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:strErroInfo preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
//                else{
////                    _holdDirectLable.text = @"多";     //看涨按钮按下 持仓就为多
////                    [_holdDirectLable setTextColor:RoseColor];
////                    [_buyCountArray addObject:@([_buyCount integerValue])];
////                    _buyCountValue += [_buyCount integerValue];
////                    _OrderCount += 1;
//                    //NSLog(@"看涨追单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
//                }
            }
        }
        
        
        //看跌
        else{
            //看跌开仓
            
            if([sender.titleLabel.text isEqualToString:@"看跌"]){
                int ret = 0;
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
                NSString *strCmd = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",quickOrder.strPassword,@"=",_buyCount,@"=",@"2",@"=",_loseLimtedTextField.text,@"=",_winLimitedTextField.text,@"=",@"1",@"=",@"0",@"=",@"0"];
                
                @try{
                    _tradeKind = TradeKindeSellOut;
                    ret = [quickOrder.quickOrder SendOrder:@"InsertOrder" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
                    NSLog(@"看跌开仓 strcmd == %@",[NSString stringWithFormat:@"%@%@%@%@%ld",quickOrder.strFunAcc,@"=",self.sCode,@"=",_buyCountValue]);
                    NSLog(@"看跌开仓========%@ erro===========%@",strOut,strErroInfo);
                }
                @catch(NSException *s){
                    ret = -1;
                    [strErroInfo appendString: @"下单失败,请检查网络连接"];
                }
                if(ret < 0 ){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:strErroInfo preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
//                else{
//                    //卖出交易成功
//                    _holdDirectLable.text = @"空";//看跌按钮按下 持仓就为多
//                    [_holdDirectLable setTextColor:DropColor];
//                    [_dropButton setTitle:@"追单" forState:UIControlStateNormal];
//                    [_riseButton setTitle:@"反向开仓" forState:UIControlStateNormal];
//                   // NSLog(@"看跌下单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
//                    _buyCountValue += [_buyCount integerValue];
//                    [_buyCountArray addObject:@([_buyCount integerValue])];
//                    _OrderCount += 1;
//                }
            }
            //反向开仓
            else if ([sender.titleLabel.text isEqualToString:@"反向开仓"]){
                int ret = 0;
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
         
                @try{
                    _tradeKind = TradeKindRollBackDown;//看跌反向开仓
                    //ret = [quickOrder.quickOrder SendOrder:@"InsertOrder" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
                    ret = [quickOrder.quickOrder SendOrder:@"RollBackOrder" strCmd:[NSString stringWithFormat:@"%@%@%@%@%ld",quickOrder.strFunAcc,@"=",self.sCode,@"=",_buyCountValue] strOut:&strOut strErrInfo:&strErroInfo];
                  // [quickOrder sendOrder:@"RollBackOrder" strCmd:[NSString stringWithFormat:@"%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",@"-1"]];

                    NSLog(@"看跌反向开仓 strcmd == %@",[NSString stringWithFormat:@"%@%@%@%@%ld",quickOrder.strFunAcc,@"=",self.sCode,@"=",_buyCountValue]);
                    NSLog(@"看跌反向开仓 ===== %@,  erro========%@",strOut,strErroInfo);

                }
                @catch(NSException *s){
                    ret = -1;
                    [strErroInfo appendString: @"下单失败,请检查网络连接"];
                }
                if(ret < 0 ){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:strErroInfo preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
//                else{
//                    _holdDirectLable.text = @"空";//看跌按钮按下 持仓就为多
//                    [_holdDirectLable setTextColor:DropColor];
//                    //反向开仓 重新计数 清空现在的数据
//                    _buyCountValue = 0;
//                    _OrderCount = 0;
//                    [_buyCountArray removeAllObjects];
//                    [_dropButton setTitle:@"追单" forState:UIControlStateNormal];
//                    [_riseButton setTitle:@"反向开仓" forState:UIControlStateNormal];
//                    //NSLog(@"看跌反向开仓:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
//                    [_buyCountArray addObject:@([_buyCount integerValue])];
//                    _buyCountValue += [_buyCount integerValue];
//                    _OrderCount += 1;
//                }
            }
            //追单
            else{
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
                int ret = 0;
                @try{
                    _tradeKind = TradeKindChasingDown;//看跌追单
                    NSString *strCmd = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",quickOrder.strPassword,@"=",_buyCount,@"=",@"2",@"=",_loseLimtedTextField.text,@"=",_winLimitedTextField.text,@"=",@"1",@"=",@"0",@"=",@"0"];
                    ret = [quickOrder.quickOrder SendOrder:@"InsertOrder" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
                     NSLog(@"看跌追单结果=====%@  erro ==== %@",strOut,strErroInfo);
                }
                @catch(NSException *s){
                    ret = -1;
                    [strErroInfo appendString: @"下单失败,请检查网络连接"];
                }
                if(ret < 0 ){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:strErroInfo preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
//                else{
//                    _holdDirectLable.text = @"空";//看跌按钮按下 持仓就为多
//                    [_holdDirectLable setTextColor:DropColor];
//                    [_buyCountArray addObject:@([_buyCount integerValue])];
//                    _buyCountValue += [_buyCount integerValue];
//                    _OrderCount += 1;
//                    //NSLog(@"看跌追单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
//                }
            }
        }
    }
    //清仓
    else{
        //全清
        if(sender.tag == 502){
            //全清
           
            NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
            NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
            int ret = 0;
            @try{
                 _tradeKind = TradeKindClearAll;
                NSLog(@"qingcang");
                NSString *strCmd =[ NSString stringWithFormat:@"%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",@"0" ];
                ret = [quickOrder.quickOrder ClearOrder:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
            }
            @catch(NSException *s){
                ret = -1;
                [strErroInfo appendString: @"下单失败,请检查网络连接"];
            }
            if(ret < 0 ){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:strErroInfo preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            //清仓成功
//            else{
////                //清仓成功 在返回消息处更改
////                _OrderCount = 0;
////                _buyCountValue  = 0;
////                [_buyCountArray removeAllObjects];
////                _holdDirectLable.text = @"--";
////                [_holdDirectLable setTextColor:[UIColor yellowColor]];
////                [_dropButton setTitle:@"看跌" forState:UIControlStateNormal];
////                [_riseButton setTitle:@"看涨" forState:UIControlStateNormal];
//            }
  
        }
        //分批清仓
        else{
            //分批清仓
           
            
            NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
            NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
            int ret = 0;
            @try{
                 _tradeKind = TradeKindClearFenPi;
                NSLog(@"分批清仓");
                NSString *strCmd =[ NSString stringWithFormat:@"%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",@"1" ];//分批清仓 怎么操作的
                ret = [quickOrder.quickOrder ClearOrder:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
            }
            @catch(NSException *s){
                ret = -1;
                [strErroInfo appendString: @"下单失败,请检查网络连接"];
            }
            if(ret < 0 ){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:strErroInfo preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            //清仓成功
//            else{
//
//               // NSLog(@"分批清仓成功");
////                if(_OrderCount>0){
////                    _buyCountValue -= [[_buyCountArray lastObject] integerValue];
////                    [_buyCountArray removeLastObject];
////                    _OrderCount -= 1;
////                    if(_OrderCount == 0){
////                        _holdDirectLable.text = @"--";
////                        [_dropButton setTitle:@"看跌" forState:UIControlStateNormal];
////                        [_riseButton setTitle:@"看涨" forState:UIControlStateNormal];
////                    }
////                }
//            }
        }
    }
   // _holdCountLable.text = [NSString stringWithFormat:@"%ld%@",(long)_buyCountValue,@"手"];
}


// 下单手数按键按下
- (IBAction)setCountOfChips:(UIButton *)sender{
    
    static NSInteger oldTag;
    static UIButton *oldBtn;
    // +键按下
    if([sender.titleLabel.text integerValue] == 0){
        [self editChip:sender];
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _buyCount = sender.titleLabel.text;
        [oldBtn  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        oldBtn = sender;
        //[sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    else{
        //选中颜色变黑
//        NSLog(@"按键按下=============");
//        NSLog(@"oldbtn.tag = %d  send.tag = %d",oldTag,sender.tag);
        _buyCount = sender.titleLabel.text;
        [sender  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [oldBtn  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //手数更换
         oldTag = sender.tag;
         oldBtn = sender;
    }
    NSLog(@"下单手数 = ===== %@",_buyCount);
}



#pragma --mark 业务逻辑




//getter方法 of modelsDict
- (NSMutableDictionary<NSString *,Y_KLineGroupModel *> *)modelsDict
{
    if (!_modelsDict) {
        _modelsDict = @{}.mutableCopy;
    }
    return _modelsDict;
}

//dataSource of stockView

-(id) stockDatasWithIndex:(NSInteger)index
{
    
    NSString *type;
    switch (index) {
        case 0:
        {
            //分时图时 打开代理 实时更新数据
            //AppDelegate * app = [UIApplication sharedApplication].delegate;
           // app.iceQuote.delegate = self; //设置代理在stockChartView中实现
            type = @"1min";
            
        }
            break;
        case 1:
        {
            type = @"1min";
        }
            break;
        case 2:
        {
            type = @"5min";
        }
            break;
        case 3:
        {
            type = @"15min";
        }
            break;
        case 4:
        {
            type = @"1week";
        }
            break;
        case 5:
        {
            type = @"1day";
        }
            break;
        case 6:
        {
            type = @"1month";
        }
            break;
            
        default:
            break;
    }
    self.currentIndex = index;
    self.type = type;
    
    if(!_refreshTimer){
        NSLog(@"开启定时器");
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(reloadData) userInfo:nil repeats:YES];//每分钟刷新
    }
    //定时刷新数据
//    if(index == 0){
//        if(!_refreshTimer){
//            NSLog(@"开启定时器");
//            _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(reloadData) userInfo:nil repeats:YES];//每分钟刷新
//        }
//    }
//    else{
//        if(_refreshTimer != nil){
//            NSLog(@"关闭定时器");
//            [_refreshTimer invalidate];
//            _refreshTimer = nil;
//        }
//    }
    
    //无数据 重新下载数据
    if(![self.modelsDict objectForKey:type])
    {
        [self reloadData];

    } else {
        return [self.modelsDict objectForKey:type].models;
    }
    return nil;
}




#pragma mark   订阅和取消订阅

- (void)subscibe{
    ICEQuote* iceQuote = [ICEQuote shareInstance];
    NSString* cmdType = @"CTP,";
    NSString *strAcc = [NSString stringWithFormat:@"%@%@%@",iceQuote.strFunAcc,@"=",iceQuote.userID];
    cmdType =  [cmdType stringByAppendingString:strAcc];
    [iceQuote SubscribeQuote:cmdType strCmd:self.sCode];
}

- (void)unSubscibe{
   
    ICEQuote *iceQuote = [ICEQuote shareInstance];
    NSString* cmdType = @"CTP,";
    //NSString *strAcc = [NSString stringWithFormat:@"%@%@%@",quickOrder.strFunAcc,@"=",quickOrder.strUserId ];
    NSString *strAcc = [NSString stringWithFormat:@"%@%@%@",iceQuote.strFunAcc,@"=",iceQuote.userID];
    cmdType =  [cmdType stringByAppendingString:strAcc];
    [iceQuote UnSubscribeQuote:cmdType strCmd:self.sCode];
}

#pragma mark 数据处理

//获取分钟线图
- (NSMutableArray *)getMinData:(NSMutableArray *)array dataType:(NSString*)type{
    
    __block NSMutableArray *dataArray = [NSMutableArray array];
    __block NSString *time = [[NSString alloc]init];
    //NSEnumerator *enumerator = [[NSEnumerator alloc]init];
    __block float highPrice ;
    __block float lowPrice ;
    __block float closePrice ;
    __block float openPrice ;
    __block float colum ;

    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *string = obj;
        NSArray* array1 = [string componentsSeparatedByString:@","];
        NSInteger min = 0;
        
        if([type isEqualToString:@"1min"]){
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];//包括时间 开盘价  最高价 最低价 收盘价 持仓数
            NSMutableString *date = [[NSMutableString alloc]initWithString:array1[0]];
            [date appendString:array1[1]];
            NSMutableString *timeString = [[NSMutableString alloc]initWithString:array1[1]];
            [timeString deleteCharactersInRange:NSMakeRange(4,2)];
            [timeString insertString:@":" atIndex:2];
            
            array[0] = timeString;
            array[1] = @([array1[2] floatValue]);//open
            array[2] = @([array1[4] floatValue]);//hig
            array[3] = @([array1[5] floatValue]);//low
            array[4] = @([array1[3] floatValue]);//close
            array[5] = @([array1[7] floatValue]);//colum
            [dataArray addObject:array];
        }
        
        else{
            
            if([type isEqualToString:@"5min"]){
                min = 5;
            }
            else if([type isEqualToString:@"15min"])
            {
                min = 15;
            }
            if((idx+1)%min == 1){
                NSMutableString *date = [[NSMutableString alloc]initWithString:array1[0]];
                [date appendString:array1[1]];
                //NSMutableString *timeString = [[NSMutableString alloc]initWithString:array1[1]];
                NSMutableString *timeString = [[NSMutableString alloc]initWithString:array1[1]];
                [timeString deleteCharactersInRange:NSMakeRange(4,2)];
                [timeString insertString:@":" atIndex:2];
                // [timeString1 appendString:timeString];
                //_array[0] = timeString;//0分钟 5分钟 10分钟作为时间
                time  = timeString;
                openPrice =[array1[2] floatValue]; //5分钟的 开盘价是第一天的开盘价
                highPrice = [array1[4] floatValue];
                lowPrice = [array1[5] floatValue];
                colum    = [array1[7] floatValue];
            }
            else{
                if(highPrice < [array1[4] floatValue]){
                    highPrice = [array1[4] floatValue];//最高价 为五分钟内最高价
                }
                if(lowPrice > [array1[5] floatValue]){
                    lowPrice = [array1[5] floatValue];//最低价为五分钟内最低价
                }
                colum += [array1[7] floatValue];//成交量是五分钟成交量之和
                
                if((idx+1)%min == 0){
                    
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];
                    closePrice = [array1[3] floatValue];//closePrice 第五分钟的收盘价
                    array[0] = time;
                    array[1] = @(openPrice);
                    array[2] = @(highPrice);
                    array[3] = @(lowPrice);
                    array[4] = @(closePrice);
                    array[5] = @(colum);
                    
                    [dataArray addObject:array];
                    switch (min) {
                        case 5:
                            [_fiveMinsData addObject:array];
                            break;
                        case 15:
                            [_fifteenMinsData addObject:array];
                            break;
                        default:
                            break;
                    }
                    openPrice = 0;
                    highPrice = 0;
                    lowPrice = 0;
                    closePrice = 0;
                    colum = 0;
                }
            }
        }
    }];
        
    return dataArray;
}
//获取日线数据
-(NSMutableArray *)getDayData:(NSMutableArray*)dayData type:(NSString*)type{
    
    __block NSMutableArray *dataArray = [NSMutableArray array];
    __block NSString *time = [[NSString alloc]init];
    //NSEnumerator *enumerator = [[NSEnumerator alloc]init];
    __block float highPrice ;
    __block float lowPrice ;
    __block float closePrice ;
    __block float openPrice ;
    __block float colum ;
    [dayData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *string = obj;
        NSArray* array1 = [string componentsSeparatedByString:@","];
        
        
        if ([type isEqualToString:@"1day"]){
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];
            NSMutableString *dateString = [[NSMutableString alloc]initWithString:array1[0]];
            [dateString insertString:@"-" atIndex:4];
            [dateString insertString:@"-" atIndex:7];
            array[0] = dateString;
            array[1] = @([array1[1] floatValue]);//open
            array[2] = @([array1[3] floatValue]);//high
            array[3] = @([array1[4] floatValue]);//low
            array[4] = @([array1[2] floatValue]);//close
            array[5] = @([array1[6] floatValue]);//colum
            [dataArray addObject:array];
            [_dayData addObject:array];
        }
        else if([type isEqualToString:@"1week"]){
            
            static NSInteger lastWeek;
            NSMutableString *dateString = [[NSMutableString alloc]initWithString:array1[0]];
            [dateString insertString:@"-" atIndex:4];
            [dateString insertString:@"-" atIndex:7];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yy-MM-dd"];
            NSDate *date = [formatter dateFromString:dateString];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSInteger week = [gregorianCalendar component:NSCalendarUnitWeekOfYear fromDate:date];
            if (week != lastWeek){
                lastWeek = week;
                //除了第一天
                if(idx > 0){
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];
                    //每周最后一个交易日的时间
                    array[0] = time;
                    array[1] = @(openPrice);//每周第一天的开盘价
                    array[2] = @(highPrice);
                    array[3] = @(lowPrice);
                    array[4] = @(closePrice);
                    array[5] = @(colum);
                    [dataArray addObject:array];
                    //[_weekData addObject:array];
                    //highPrice = 0;
                    colum = 0;
                }
                //第一次
                lowPrice = [array1[4] floatValue];
                highPrice = [array1[3] floatValue];
                colum  += [array1[6] floatValue];
                openPrice = [array1[1] floatValue];
            }
            else{
                if(highPrice < [array1[3] floatValue]){
                    highPrice = [array1[3] floatValue];//最高价 为五分钟内最高价
                }
                //始终为0
                if(lowPrice > [array1[4] floatValue]){
                    lowPrice = [array1[4] floatValue];
                }
                colum  += [array1[6] floatValue];//成交量
            }
            time = dateString;//保留每天的时间 这样在变成下一周后可以取得本周最后一天的日期
            closePrice = [array1[2] floatValue];//保留每天的时间 这样在变成下一周后可以取得本周最后一天的日期
        }
        else{
            static NSInteger lastMonth;
            NSMutableString *dateString = [[NSMutableString alloc]initWithString:array1[0]];
            [dateString insertString:@"-" atIndex:4];
            [dateString insertString:@"-" atIndex:7];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yy-MM-dd"];
            NSDate *date = [formatter dateFromString:dateString];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSInteger month = [gregorianCalendar component:NSCalendarUnitMonth fromDate:date];
            if (month != lastMonth){
                
                lastMonth = month;
                
                //除了第一tian
                if(idx > 0){
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];
                    //每周最后一个交易日的时间
                    array[0] = time;
                    array[1] = @(openPrice);//每周第一天的开盘价
                    array[2] = @(highPrice);
                    array[3] = @(lowPrice);
                    array[4] = @(closePrice);
                    array[5] = @(colum);
                    [dataArray addObject:array];
                   // [_monthData addObject:array];
                    //highPrice = 0;
                    colum = 0;
                }
                lowPrice = [array1[4] floatValue];
                colum    += [array1[6] floatValue];
                highPrice = [array1[3] floatValue];
                openPrice = [array1[1] floatValue];
            }
            else{
                if(highPrice < [array1[3] floatValue]){
                    highPrice = [array1[3] floatValue];
                }
                if(lowPrice > [array1[4] floatValue]){
                    lowPrice = [array1[4] floatValue];
                }
                colum    += [array1[6] floatValue];//成交量
            }
            //同一周的
            time = dateString;//保留每天的时间 这样在变成下一yue后可以取得本周最后一天的日期
            closePrice = [array1[2] floatValue];//保留每天的时间 这样在变成下一yue后可以取得本周最后一天的日期
        }
        
    }];
    return dataArray;
}





//下载数据
- (void)downLoadData{
    [self downloadDayData];
    [self downloadMinData];
    
}

- (void)downloadMinData{
    
    ICEQuote* iceQuote = [ICEQuote shareInstance];
    NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@" ,self.sCode,@"=",iceQuote.userID];
    NSMutableArray *minArray = [NSMutableArray array];
    @try {
        NSLog(@"分钟线 ++++++++++++");
        minArray  = [iceQuote getKlineData:strCmd type:@"minute"];
        if(minArray.count == 0){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"无分钟数据" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else{

            _MinData = [self getMinData:minArray dataType:@"1min"];
            _fiveMinsData = [self getMinData:minArray dataType:@"5min"];
            _fifteenMinsData = [self getMinData:minArray dataType:@"15min"];

            if(_stockChartLangVC){
                [[NSNotificationCenter defaultCenter]postNotificationName:@"changeMinDataNotity" object:nil userInfo:@{@"minData":_MinData,@"fifteenMinData":_fifteenMinsData,@"fiveMinData":_fiveMinsData}];
            }
        }

    } @catch (NSException *s) {
        NSLog(@"get data erro is %@",s);
    }
    
}
//下载日K线数据
- (void)downloadDayData{
    ICEQuote* iceQuote = [ICEQuote shareInstance];
    NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@" ,self.sCode,@"=",iceQuote.userID];
    NSMutableArray *dayArray = [NSMutableArray array];
    @try {
        NSLog(@"日线 ++++++++++++");
        NSMutableArray *array = [iceQuote getKlineData:strCmd type:@"day"];
        
        if(array.count == 0){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"无日数据" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            [dayArray addObjectsFromArray:[[array reverseObjectEnumerator] allObjects]];
            _dayData = [self getDayData:dayArray type:@"1day"];
            _monthData = [self getDayData:dayArray type:@"1month"];
            _weekData = [self getDayData:dayArray type:@"1week"];
            
        }
    } @catch (NSException *exception) {
        NSLog(@"get data erro is %@",exception);
    }
}


- (void)reloadData
{
    NSLog(@"reload data");
    NSMutableArray *data = [NSMutableArray array];
    
    [self downloadMinData];//分钟线要及时加载 更新
    
    switch (self.currentIndex) {
        case 0:
            [data addObjectsFromArray:_MinData];
            break;
        case 1:
            [data addObjectsFromArray:_MinData];
            break;
        case 2:
            [data addObjectsFromArray:_fiveMinsData];
            break;
        case 3:
            [data addObjectsFromArray:_fifteenMinsData];
            break;
        case 4:
            [data addObjectsFromArray:_weekData];
            break;
        case 5:
            [data addObjectsFromArray:_dayData];
            break;
        case 6:
            [data addObjectsFromArray:_monthData];
            break;
        default:
            break;
    }
    
    
    self.groupModel  = [Y_KLineGroupModel objectWithArray:data];
    [self.modelsDict setObject:_groupModel forKey:self.type];//model 字典 键值编程 更新M_groupModel
    [self.stockChartView reloadData];
    [self.stockChartView.kLineView reDraw];//重绘kline
}

#pragma --mark Getter方法 of Y_StockChartView
- (void)itemModels{
    _stockChartView.itemModels = @[
                                   
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"分时" type:Y_StockChartcenterViewTypeTimeLine],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"1分"  type:Y_StockChartcenterViewTypeKline],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"5分"  type:Y_StockChartcenterViewTypeKline],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"15分" type:Y_StockChartcenterViewTypeKline],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"周线" type:Y_StockChartcenterViewTypeKline],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"日线" type:Y_StockChartcenterViewTypeKline],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"月线" type:Y_StockChartcenterViewTypeKline],
                                   ];
}

//getter 方法
- (Y_StockChartView *)stockChartView
{
    if(!_stockChartView) {
        //_stockChartView = [Y_StockChartView new];
        _stockChartView = [[Y_StockChartView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT+200)];
        _stockChartView.dataSource = self;
        [self.scrollView addSubview:_stockChartView];

        self.scrollView.contentSize = _stockChartView.size;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        tap.numberOfTapsRequired = 2;
        [_stockChartView addGestureRecognizer:tap];
    }
    return _stockChartView;
}

//横竖屏切换
- (void)dismiss
{
    NSLog(@"竖屏变横屏 dismisss");
    //停止计时器
//    if(_refreshTimer){
//        [_refreshTimer invalidate];
//    }

    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    appdelegate.isEable = YES;//横屏
    [self unSubscibe];
    _stockChartLangVC = [[Y_StockChartLandScapeViewController alloc]init];
    _stockChartLangVC.sCode = _sCode;
    _stockChartLangVC.dayData = [NSArray arrayWithArray:_dayData];
    _stockChartLangVC.MinData = [NSArray arrayWithArray:_MinData];
    _stockChartLangVC.weekData = [NSArray arrayWithArray:_weekData];
    _stockChartLangVC.monthData = [NSArray arrayWithArray:_monthData];
    _stockChartLangVC.fiveMinsData = [NSArray arrayWithArray:_fiveMinsData];
    _stockChartLangVC.fifteenMinsData = [NSArray arrayWithArray:_fifteenMinsData];
    
    _stockChartLangVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:_stockChartLangVC animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_loseLimtedTextField resignFirstResponder];
    [_winLimitedTextField resignFirstResponder];


}



#pragma --mark  keyboard delegate
- (void)keyboardWillHide:(NSNotification*)aNSNotification{
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }];
}

- (void)keyboardWillShow:(NSNotification*)aNSNotification{
  
    NSValue *keyBoardBeginBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect  beginRect=[keyBoardBeginBounds CGRectValue];
    CGFloat deltaY=beginRect.size.height;
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, -deltaY, self.view.frame.size.width, self.view.frame.size.height)];
    }];
}


#pragma --mark Pickerview delegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSInteger count = 100/[self.futu_price_step floatValue];
    return  count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 40;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"selected");
    //止损
    if(pickerView.tag == 1000 ){
        _loseLimtedTextField.text = [NSString stringWithFormat:@"%.1f",(row+1) * [self.futu_price_step floatValue]];
    }
    //止盈
    else{
        _winLimitedTextField.text = [NSString stringWithFormat:@"%.1f",(row+1) * [self.futu_price_step floatValue]];
    }
}
//设置UIPicker 的每个选项的view 这里设为uitextfield
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{

    UITextField *lossField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    if(pickerView.tag == 1000){
        lossField.backgroundColor = DropColor;
    }
    else{
        lossField.backgroundColor = RoseColor;
    }
    lossField.textAlignment = NSTextAlignmentCenter;
    lossField.text = [NSString stringWithFormat:@"%.1f",(row+1) * [self.futu_price_step floatValue]];//字符串转数字
    lossField.textColor = [UIColor whiteColor];
    return lossField;
}

#pragma mark 系统函数
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of  nmthat can be recreated.
}
//移除通知
- (void)dealloc{
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"quoteNotity" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tradeNotify" object:nil];
    
}
@end
