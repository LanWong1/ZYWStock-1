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

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_MAX_LENGTH MAX(kScreenWidth,kScreenHeight)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

@interface Y_StockChartViewController ()<Y_StockChartViewDataSource,ICEQuoteDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
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
@property (nonatomic, strong) NSMutableArray *buyCountArray;
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

@property (strong,nonatomic) Y_StockChartLandScapeViewController *stockChartVC;

@property (strong,nonatomic) UIView *buttomBtnView;

@property (strong,nonatomic) UIScrollView *scrollView;
 @end

@implementation Y_StockChartViewController




#pragma --mark icetool delegate 用于传值 更新数据
//从icequote中获取数据 更新图像
- (void)refreshTimeline:(NSString *)s{
    NSLog(@"delegate.........%@",s);
    /*
     Y_StockChartViewItemModel *itemModel = self.itemModels[index];
     Y_StockChartCenterViewType type = itemModel.centerViewType;
     self.kLineView.kLineModels = (NSArray *)stockData;//新的数据
     self.kLineView.MainViewType = type;
     [self.kLineView reDraw];//重绘图像
     */
    //可从这里传入新的数据 然后重绘数据
}


-(void)refrenshTest:(NSString *)s{
    NSLog(@"aaaa     %@",s);
}


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
    NSLog(@"will appear  出现啦");
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//设置返回字体颜色
    self.navigationController.navigationBar.barTintColor = DropColor;//导航栏背景色
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};//设置标题文字为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;//设置状态时间文字为白色
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor blackColor]};
   
}

- (void)viewDidLoad {
 
    [super viewDidLoad];
 
//    _tradeView = [[UIView alloc]init];
//    _tradeView.backgroundColor = [UIColor backgroundColor];
//    [self.view addSubview:_tradeView];
    
    self.navigationItem.title = self.sCode;
    self.view.backgroundColor = [UIColor backgroundColor];
    [self addScrollView];
    self.stockChartView.backgroundColor = [UIColor backgroundColor];//调用了getter方法
    self.currentIndex = -1;
    [self addBottomBtnView];
    [self itemModels];//加载数据
    _buyCountArray = [NSMutableArray array];
    [self subscibe];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];//键盘将要隐藏通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];//键盘将要显示
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tradeResult:) name:@"tradeNotify" object:nil];
}
//交易成功返回消息
- (void)tradeResult:(NSNotification*)notify{
    
    NSLog(@"交易结果========%@   type = %@",notify.userInfo[@"message"],notify.userInfo[@"type"]);
    //float x = r
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 600, 30)];
    
    if([notify.userInfo[@"type"] isEqualToString:@"2"]){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  // 震动
        AudioServicesPlaySystemSound(1007);
        lable.text = notify.userInfo[@"message"];
        lable.textColor = [UIColor whiteColor];
        lable.font = [UIFont systemFontOfSize:15];
        lable.textAlignment = NSTextAlignmentLeft;
        lable.backgroundColor = [UIColor clearColor];
        [_stockChartView addSubview:lable];
        [UIView animateWithDuration:5 animations:^{
            [lable setFrame:CGRectMake(lable.frame.origin.x - 600, 100, 600, 30)];
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"lable disappear");
        [lable removeFromSuperview];
    });
    
    


}

#pragma --mark 添加views
// scrollview
- (void)addScrollView{
    _scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
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
    tradeBtn.alpha = 0.9;
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
    checkBtn.alpha = 0.9;
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
            _tradeView.alpha = 0.9;
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
        if([_buyCount integerValue] == 0){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"委托手数不能为零" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        //看涨
        else if(sender.tag == 500){
           //看涨
            _holdDirectLable.text = @"多";//看涨按钮按下 持仓就为多
            [_holdDirectLable setTextColor:RoseColor];
            if([sender.titleLabel.text isEqualToString:@"看涨"]){
                 int ret = 0;
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
                NSString *strCmd = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",quickOrder.strPassword,@"=",_buyCount,@"=",@"1",@"=",_loseLimtedTextField.text,@"=",_winLimitedTextField.text,@"=",@"1",@"=",@"0",@"=",@"0"];
                @try{
                    ret = [quickOrder.quickOrder SendOrder:@"InsertOrder" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
                    NSLog(@"看涨下单结果 = %@   erro=======%@",strOut,strErroInfo);
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
                else{

                    [_riseButton setTitle:@"追单" forState:UIControlStateNormal];
                    [_dropButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                    //NSLog(@"看涨下单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
                    [_buyCountArray addObject:@([_buyCount integerValue])];
                    _buyCountValue += [_buyCount integerValue];
                    _OrderCount += 1;
                }
            }
            //反向开仓
            else if ([sender.titleLabel.text isEqualToString:@"反向开仓"]){
                int ret = 0;
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
                @try{
                    ret = [quickOrder.quickOrder SendOrder:@"RollBackOrder" strCmd:[NSString stringWithFormat:@"%@%@%@%@%ld",quickOrder.strFunAcc,@"=",self.sCode,@"=",_buyCountValue] strOut:&strOut strErrInfo:&strErroInfo];
                    NSLog(@"看涨反向开仓结果======%@   erro ==== %@",strOut,strErroInfo);
                 
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
                else{
                    //反向开仓 重新计数 清空现在的数据
                    _buyCountValue = 0;
                    _OrderCount = 0;
                    [_buyCountArray removeAllObjects];
                    [_riseButton setTitle:@"追单" forState:UIControlStateNormal];
                    [_dropButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                    //NSLog(@"看涨反向开仓:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
                    [_buyCountArray addObject:@([_buyCount integerValue])];
                    _buyCountValue += [_buyCount integerValue];
                    _OrderCount += 1;
                }
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
                else{
                    [_buyCountArray addObject:@([_buyCount integerValue])];
                    _buyCountValue += [_buyCount integerValue];
                    _OrderCount += 1;
                    //NSLog(@"看涨追单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
                }
            }
        }
        //看跌
        else{
            //看跌开仓
            _holdDirectLable.text = @"空";//看跌按钮按下 持仓就为多
            [_holdDirectLable setTextColor:DropColor];
            if([sender.titleLabel.text isEqualToString:@"看跌"]){
                int ret = 0;
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
                NSString *strCmd = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",quickOrder.strPassword,@"=",_buyCount,@"=",@"2",@"=",_loseLimtedTextField.text,@"=",_winLimitedTextField.text,@"=",@"1",@"=",@"0",@"=",@"0"];
                @try{
                    ret = [quickOrder.quickOrder SendOrder:@"InsertOrder" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
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
                else{
     
                    [_dropButton setTitle:@"追单" forState:UIControlStateNormal];
                    [_riseButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                   // NSLog(@"看跌下单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
                    _buyCountValue += [_buyCount integerValue];
                    [_buyCountArray addObject:@([_buyCount integerValue])];
                    _OrderCount += 1;
                }
            }
            //反向开仓
            else if ([sender.titleLabel.text isEqualToString:@"反向开仓"]){
                int ret = 0;
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
                @try{
                    ret = [quickOrder.quickOrder SendOrder:@"RollBackOrder" strCmd:[NSString stringWithFormat:@"%@%@%@%@%ld",quickOrder.strFunAcc,@"=",self.sCode,@"=",_buyCountValue] strOut:&strOut strErrInfo:&strErroInfo];
                    NSLog(@"看跌反向开仓 ===== %@,  erro========%@",strOut,strErroInfo);
                    //[quickOrder sendOrder:@"RollBackOrder" strCmd:[NSString stringWithFormat:@"%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",@"-1"]];
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
                else{
                    //反向开仓 重新计数 清空现在的数据
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
                }
            }
            //追单
            else{
                NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
                NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
                int ret = 0;
                @try{
                    
                    NSString *strCmd = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",quickOrder.strFunAcc,@"=",self.sCode,@"=",quickOrder.strPassword,@"=",_buyCount,@"=",@"1",@"=",_loseLimtedTextField.text,@"=",_winLimitedTextField.text,@"=",@"1",@"=",@"0",@"=",@"0"];
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
                else{
                    [_buyCountArray addObject:@([_buyCount integerValue])];
                    _buyCountValue += [_buyCount integerValue];
                    _OrderCount += 1;
                    //NSLog(@"看跌追单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
                }
            }
        }
    }
    //清仓
    else{
        //全清
        if(sender.tag == 502){
            NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
            NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
            int ret = 0;
            @try{
                
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
            else{
                _OrderCount = 0;
                _buyCountValue  = 0;
                [_buyCountArray removeAllObjects];
                _holdDirectLable.text = @"--";
                [_holdDirectLable setTextColor:[UIColor yellowColor]];
                [_dropButton setTitle:@"看跌" forState:UIControlStateNormal];
                [_riseButton setTitle:@"看涨" forState:UIControlStateNormal];
            }
  
        }
        //分批清仓
        else{

            NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
            NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
            int ret = 0;
            @try{
                
                NSLog(@"qingcang");
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
            else{
                NSLog(@"分批清仓");
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
            }
        }
    }
    _holdCountLable.text = [NSString stringWithFormat:@"%ld%@",(long)_buyCountValue,@"手"];
}


// 下单手数按键按下
- (IBAction)setCountOfChips:(UIButton *)sender{
    
    static NSInteger oldTag;
    static UIButton *oldBtn ;
    if([sender.titleLabel.text integerValue] == 0){
        [self editChip:sender];
    }
    else{
        [sender  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if(sender.tag != oldTag){
            oldTag = sender.tag;
            _buyCount = sender.titleLabel.text;
            oldBtn.enabled = YES;
            sender.enabled = NO;
            [oldBtn  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            oldBtn = sender;
            NSLog(@"下单手数 = ===== %@",_buyCount);
        }
    }
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of  nmthat can be recreated.
}

-(id) stockDatasWithIndex:(NSInteger)index
{
    
    NSString *type;
    switch (index) {
        case 0:
        {
            //分时图时 打开代理 实时更新数据
            AppDelegate * app = [UIApplication sharedApplication].delegate;
            app.iceQuote.delegate = self; //设置代理在stockChartView中实现
            type = @"1min";
        }
            break;
        case 1:
        {
            type = @"1min";
        }
            break;
//        case 2:
//        {
//            type = @"1min";
//        }
//            break;
        case 2:
        {
            type = @"5min";
        }
            break;
        case 3:
        {
            type = @"30min";
        }
            break;
        case 4:
        {
            type = @"1hour";
        }
            break;
        case 5:
        {
            type = @"1day";
        }
            break;
        case 6:
        {
            type = @"1week";
        }
            break;
            
        default:
            break;
    }
    self.currentIndex = index;
    self.type = type;
    
    //定时刷新数据
    if(index == 0){
        if(!_refreshTimer){
            NSLog(@"开启定时器");
            _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(reloadData) userInfo:nil repeats:YES];//每分钟刷新
        }
    }
    else{
        if(_refreshTimer != nil){
            NSLog(@"关闭定时器");
            [_refreshTimer invalidate];
            _refreshTimer = nil;
        }
    }
    
    //无数据 重新下载数据
    if(![self.modelsDict objectForKey:type])
    {
        [self reloadData];

    } else {
        return [self.modelsDict objectForKey:type].models;
    }
    

    return nil;
}




//订阅


- (void)subscibe{
    NSLog(@"subsctibe ........=============");
    ICEQuote* iceQuote = [ICEQuote shareInstance];
    ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
    NSString* cmdType = @"CTP,";
    //NSString *strAcc = [NSString stringWithFormat:@"%@%@%@",quickOrder.strFunAcc,@"=",quickOrder.strUserId ];
    NSString *strAcc = [NSString stringWithFormat:@"%@%@%@",quickOrder.strFunAcc,@"=",iceQuote.userID ];
    cmdType =  [cmdType stringByAppendingString:strAcc];
    NSLog(@"cmdtype = %@   scode = %@",cmdType,self.sCode);
    [iceQuote SubscribeQuote:cmdType strCmd:self.sCode];
}


- (void)reloadData
{
    NSLog(@"reload data");
    NSMutableArray *dataArray = [NSMutableArray array];
    NSMutableArray *data = [NSMutableArray array];
    NSEnumerator *enumerator = [[NSEnumerator alloc]init];
    ICEQuote* iceQuote = [ICEQuote shareInstance];
    NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@" ,self.sCode,@"=",iceQuote.userID];
    if([self.type isEqualToString: @"1min"]){
        @try{
            NSLog(@"分钟线 ++++++++++++");
           // NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@" ,self.sCode,@"=",iceQuote.userID];
            NSMutableArray *arrayTemp = [iceQuote getKlineData:strCmd type:@"minute"];
            //NSMutableArray *arrayTemp = [iceQuote getKlineData:self.sCode type:@"minute"];
            if(arrayTemp.count == 0){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"无数据" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else{
                enumerator =[arrayTemp objectEnumerator];
            }
        }
        @catch(ICEException *s){
            NSLog(@"get min erro is %@",s);
        }
    }
   if([self.type isEqualToString: @"1day"]){
       @try{
           NSLog(@"日线 ++++++++++++");
           NSMutableArray *arrayTemp = [iceQuote getKlineData:strCmd type:@"day"];
           if(arrayTemp.count == 0){
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"无数据" preferredStyle:UIAlertControllerStyleAlert];
               [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
               [self presentViewController:alert animated:YES completion:nil];
           }
           else{
                enumerator =[arrayTemp objectEnumerator];
           }
       }
       @catch(ICEException *s){
           NSLog(@"getday kline erro is %@",s);
       }
    }
    //数据处理应该在model中 移动处理
    id obj = nil;
    while (obj = [enumerator nextObject]){
        NSString *string = obj;
        NSArray* array1 = [string componentsSeparatedByString:@","];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];
        if([self.type isEqualToString: @"1min"]){
            NSMutableString *date = [[NSMutableString alloc]initWithString:array1[0]];
            [date appendString:array1[1]];
            NSMutableString *timeString = [[NSMutableString alloc]initWithString:array1[1]];
            [timeString deleteCharactersInRange:NSMakeRange(4,2)];
            [timeString insertString:@":" atIndex:2];
            array[0] = timeString;
            array[1] = @([array1[2] floatValue]);
            array[2] = @([array1[4] floatValue]);
            array[3] = @([array1[5] floatValue]);
            array[4] = @([array1[4] floatValue]);
            array[5] = @([array1[7] floatValue]);
            [dataArray addObject:array];
        }
        
        else if ([self.type isEqualToString:@"1day"]){
            NSMutableString *dateString = [[NSMutableString alloc]initWithString:array1[0]];
            [dateString insertString:@"-" atIndex:4];
            [dateString insertString:@"-" atIndex:7];
            array[0] = dateString;
            array[1] = @([array1[1] floatValue]);
            array[2] = @([array1[3] floatValue]);
            array[3] = @([array1[4] floatValue]);
            array[4] = @([array1[2] floatValue]);
            array[5] = @([array1[6] floatValue]);
            [data addObject:array];
        }
       // NSMutableArray * newMarray = [NSMutableArray array];
    }
   if ([self.type isEqualToString:@"1day"]){
       NSEnumerator * enumerator1 = [data reverseObjectEnumerator];//倒序排列
       id object;
       while (object = [enumerator1 nextObject])
       {
           [dataArray addObject:object];
       }
   }
    self.groupModel  = [Y_KLineGroupModel objectWithArray:dataArray];
    [self.modelsDict setObject:_groupModel forKey:self.type];//model 字典 键值编程 更新M_groupModel
    [self.stockChartView reloadData];
    [self.stockChartView.kLineView reDraw];//重绘kline
}

#pragma --mark Getter方法 of Y_StockChartView
- (void)itemModels{
    _stockChartView.itemModels = @[
                                   //[Y_StockChartViewItemModel itemModelWithTitle:@"指标" type:Y_StockChartcenterViewTypeOther],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"分时" type:Y_StockChartcenterViewTypeTimeLine],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"1分"  type:Y_StockChartcenterViewTypeKline],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"5分"  type:Y_StockChartcenterViewTypeKline],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"30分" type:Y_StockChartcenterViewTypeKline],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"60分" type:Y_StockChartcenterViewTypeKline],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"日线" type:Y_StockChartcenterViewTypeKline],
                                   [Y_StockChartViewItemModel itemModelWithTitle:@"周线" type:Y_StockChartcenterViewTypeKline],
                                   ];
}


- (Y_StockChartView *)stockChartView
{
    if(!_stockChartView) {
        _stockChartView = [Y_StockChartView new];
        _stockChartView = [[Y_StockChartView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT+200)];
        _stockChartView.dataSource = self;
        
        [self.scrollView addSubview:_stockChartView];
        
//        [_stockChartView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.view);
//            make.left.right.equalTo(self.view);
//            //make.bottom.equalTo(self.view).offset(-30);
//            make.height.equalTo(@900);
//        }];
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
    if(_refreshTimer){
        [_refreshTimer invalidate];
    }

    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    appdelegate.isEable = YES;//横屏
    Y_StockChartLandScapeViewController *stockChartLangVC = [[Y_StockChartLandScapeViewController alloc]init];
    stockChartLangVC.sCode = _sCode;
    stockChartLangVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:stockChartLangVC animated:YES completion:nil];


}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_loseLimtedTextField resignFirstResponder];
    [_winLimitedTextField resignFirstResponder];


}


//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscape;
//}

//- (BOOL)shouldAutorotate
//{
//    return NO;
//}

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
//移除通知
- (void)dealloc{
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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
////设置uipicker 的每个选项的view 这里设为uitextfield
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
@end
