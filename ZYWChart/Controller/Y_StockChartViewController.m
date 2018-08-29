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
//#import "NetWorking.h"
#import "Y_KLineGroupModel.h"
#import "UIColor+Y_StockChart.h"
#import "AppDelegate.h"
#import "Y_StockChartLandScapeViewController.h"
#import "ICEQuote.h"
#import "ZYWTimeLineModel.h"

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
@property (nonatomic,copy) NSString *loseLimit;//下单手数
@property (nonatomic,copy) NSString *winLimit;//下单手数



@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet   UIView *tradeSetView;
@property (weak, nonatomic) IBOutlet UITextField *loseLimtedTextField;
@property (weak, nonatomic) IBOutlet UITextField *winLimitedTextField;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UIButton *button5;
@property (weak, nonatomic) IBOutlet UIButton *button6;


@property (weak, nonatomic) IBOutlet UIButton *riseOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *dropOrderBtn;
@property (strong,nonatomic) UIButton *riseButton;
@property (strong,nonatomic) UIButton *dropButton;
@property (strong,nonatomic) UIButton *clearButton;
@property (strong,nonatomic) UIPickerView *lossLimitPicker;
@property (strong,nonatomic) UIPickerView *winLimitPicker;

@property (strong,nonatomic) UITextField *textfield;



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

-(instancetype)initWithScode:(NSString *)sCodeSelect KlineDataList:(WpQuoteServerDayKLineList *)KlineDataList{
    
    self = [super init];
    if(self){
        _sCode = sCodeSelect;
        self.KlineData = KlineDataList;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
  
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor assistBackgroundColor];
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};//设置标题文字为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;//设置状态栏文字为白色
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
 self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor blackColor]};
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orderSuccessful:) name:@"success"object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transformView:) name:UIKeyboardDidShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transformView:) name:UIKeyboardDidChangeFrameNotification object:nil];
    //[self chipsButtonAddLongPress];
   // [self addTradeButtonView];
    [self addTradeSetView];
    [self addTradeButtons];
    
    self.navigationItem.title = self.sCode;
    self.view.backgroundColor = [UIColor backgroundColor];
    self.currentIndex = -1;
    self.stockChartView.backgroundColor = [UIColor backgroundColor];//调用了getter方法[UIColor whiteColor]; // [UIColor backgroundColor];//调用了getter方法
    _textfield = [[UITextField alloc]init];
}

#pragma --mark 添加views
- (void)addTradeButtonView{
    //添加xib文件 buttonView  三键
    NSArray *views = [[NSBundle mainBundle]loadNibNamed:@"buttonView" owner:self options:nil];
    _buttonView = views[0];
    [self.view addSubview:_buttonView];
    [_buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(self.view);
        make.height.equalTo(@80);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}
//筹码 止损止盈
- (void)addTradeSetView{
    //添加xib文件 buttonView  三键
    NSArray *views = [[NSBundle mainBundle]loadNibNamed:@"buttonView" owner:self options:nil];
    _tradeSetView = views[1];
    [self.view addSubview:_tradeSetView];
    [_tradeSetView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.top.equalTo(self.stockChartView.mas_bottom).offset(100);
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(self.view);
        make.height.equalTo(@200);
        //make.bottom.equalTo(_buttonView.mas_top);
        make.top.equalTo(self.stockChartView.mas_bottom);
    }];
    _loseLimtedTextField.textColor = [UIColor whiteColor];
    _winLimitedTextField.textColor = [UIColor whiteColor];
    _loseLimtedTextField.backgroundColor = DropColor;
    _winLimitedTextField.backgroundColor = RoseColor;
    [self addLimitPicker];
}

//止损止盈picker
- (void)addLimitPicker{
    _lossLimitPicker = [[UIPickerView alloc]init];
    _winLimitPicker  = [[UIPickerView alloc]init];
   
    [_tradeSetView addSubview:_lossLimitPicker];
    [_tradeSetView addSubview:_winLimitPicker];
    [_lossLimitPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(120);
        make.width.equalTo(@40);
        //make.bottom.equalTo(_tradeSetView.mas_bottom).offset(-18);
        make.height.equalTo(@60);
        make.centerY.equalTo(_loseLimtedTextField.mas_centerY);
    }];
    [_winLimitPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-120);
        make.width.equalTo(@40);
        //make.bottom.equalTo(_tradeSetView.mas_bottom).offset(-18);
        make.height.equalTo(@60);
        make.centerY.equalTo(_winLimitedTextField.mas_centerY);

    }];
    _lossLimitPicker.delegate = self;
    _lossLimitPicker.dataSource = self;
    _winLimitPicker.dataSource = self;
    _winLimitPicker.delegate = self;
    
    _lossLimitPicker.tag = 1000;
    _winLimitPicker.tag = 1001;
    
//    _lossLimitPicker.backgroundColor = [UIColor greenColor];
//    _winLimitPicker.backgroundColor = [UIColor redColor];
    _winLimitPicker.userInteractionEnabled = YES;
}
// 交易三键
-(void)addTradeButtons{
    //看涨按键
    _riseButton = [[UIButton alloc]init];
    [_riseButton setTitle:@"看涨" forState:UIControlStateNormal];
    [_riseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_riseButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _riseButton.backgroundColor = RoseColor;
    _riseButton.layer.cornerRadius = 35;
    [self.view addSubview:_riseButton];
    [_riseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.width.equalTo(@70);
        make.height.equalTo(@70);
        
    }];
    
    //看跌按键
    _dropButton = [[UIButton alloc]init];
    [_dropButton setTitle:@"看跌" forState:UIControlStateNormal];
    [_dropButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_dropButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _dropButton.backgroundColor = DropColor;
    _dropButton.layer.cornerRadius = 35;
    [self.view addSubview:_dropButton];
    [_dropButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.width.equalTo(@70);
        make.height.equalTo(@70);
    }];
    //清仓按键
    _clearButton = [[UIButton alloc]initWithFrame:CGRectMake(150, self.view.frame.size.height - 90, 35, 70)];
    [_clearButton setTitle:@"清\n仓" forState:UIControlStateNormal];
    [_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _clearButton.backgroundColor = [UIColor blueColor];
    _clearButton.titleLabel.numberOfLines = 2;
   [self.view addSubview:_clearButton];
    NSLog(@"with = %f height = %f",_clearButton.frame.size.width,_clearButton.frame.size.height);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_clearButton.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(_clearButton.frame.size.height,_clearButton.frame.size.height)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _clearButton.bounds;
    maskLayer.path = maskPath.CGPath;
    _clearButton.layer.mask = maskLayer;
    
    
    
    [_riseButton addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
    [_dropButton addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
    [_clearButton addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
    //_clearButton = [[UIButton alloc]init];
    _dropButton.tag = 501;
    _riseButton.tag = 500;
    _clearButton.tag = 502;

}
#pragma --mark 按键相关
//长按手势
- (IBAction)longPress1:(UILongPressGestureRecognizer *)gustureRecogonizeer {
    if (gustureRecogonizeer.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    UIButton *btn = (UIButton*)(gustureRecogonizeer.view);
    NSLog(@"%ld",btn.tag);
    [self editChip:btn];
}

- (IBAction)press:(UIButton*)sender {
    //看涨
    if (sender.tag == 400 || sender.tag  == 402) {
        NSLog(@"交易");
        if([_winLimitedTextField.text  isEqual: @""]||[_loseLimtedTextField.text  isEqual: @""]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"输入止损止盈" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else{
            NSLog(@"%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
            NSLog(@"order successfully");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"success" object:self userInfo:@"看涨"];
        }
    }
    //清仓
    else{
        
        NSLog(@"qingcang");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"success" object:self userInfo:@"清仓"];
    }
}


//下单键按下
-(void)pressed:(UIButton*)sender{
    if (sender.tag == 500 || sender.tag  == 501) {
        
        if([_winLimitedTextField.text  isEqual: @""]||[_loseLimtedTextField.text  isEqual: @""]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"输入止损止盈" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if(sender.tag == 500){
            
            if([sender.titleLabel.text isEqualToString:@"看涨"]){
                [_riseButton setTitle:@"追单" forState:UIControlStateNormal];
                [_dropButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                 NSLog(@"看涨下单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
            }
            else if ([sender.titleLabel.text isEqualToString:@"反向开仓"]){
                [_riseButton setTitle:@"追单" forState:UIControlStateNormal];
                [_dropButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                NSLog(@"看涨反向开仓:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
            }
            else{
                NSLog(@"看涨追单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
            }
           // [[NSNotificationCenter defaultCenter] postNotificationName:@"success" object:self userInfo:@"看涨"];
        }
        else{
            if([sender.titleLabel.text isEqualToString:@"看跌"]){
                [_dropButton setTitle:@"追单" forState:UIControlStateNormal];
                [_riseButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                NSLog(@"看跌下单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
            }
            else if ([sender.titleLabel.text isEqualToString:@"反向开仓"]){
                [_dropButton setTitle:@"追单" forState:UIControlStateNormal];
                [_riseButton setTitle:@"反向开仓" forState:UIControlStateNormal];
                NSLog(@"看跌反向开仓:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
            }
            else{
                NSLog(@"看跌追单:%@%@%@",_buyCount, _winLimitedTextField.text,_loseLimtedTextField.text);
            }
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"success" object:self userInfo:@"看跌"];
        }
    }
    //清仓
    else{
        
        NSLog(@"qingcang");
        [_dropButton setTitle:@"看跌" forState:UIControlStateNormal];
        [_riseButton setTitle:@"看涨" forState:UIControlStateNormal];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"success" object:self userInfo:@"清仓"];
    }
}
#pragma --mark  下单成功通知 succesful notifications
//- (void)orderSuccessful:(NSNotification *)notification{
//
//    if([notification.userInfo isEqual:@"看涨"]){
//
//        [_riseButton setTitle:@"追单" forState:UIControlStateNormal];
//        [_dropButton setTitle:@"反向开单" forState:UIControlStateNormal];
//    }
//    else if([notification.userInfo isEqual:@"看跌"]){
//        [_dropButton setTitle:@"追单" forState:UIControlStateNormal];
//        _riseButton setTitle:@"反向开单" forState:UIControlStateNormal];
//    }
//    else{
//        [_dropButton setTitle:@"看跌" forState:UIControlStateNormal];
//        [_riseButton setTitle:@"看涨" forState:UIControlStateNormal];
//    }
//}
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
            NSLog(@"changeed");
            oldTag = sender.tag;
            _buyCount = sender.titleLabel.text;
            NSLog(@"%@",_buyCount);
            oldBtn.enabled = YES;
            sender.enabled = NO;
            [oldBtn  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            oldBtn = sender;
        }
    }
    
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
    //无数据 重新下载数据
    if(![self.modelsDict objectForKey:type])
    {
        [self reloadData];
    } else {
        return [self.modelsDict objectForKey:type].models;
    }
    return nil;
}
//加载数据

- (void)reloadData
{
    NSLog(@"get kline data");
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        //[app.iceQuote Connect2Quote];
        //self.timeData =
        //[app.iceQuote getKlineData:self.sCode type:self.type];
        NSMutableArray *dataArray = [NSMutableArray array];
        NSMutableArray *data = [NSMutableArray array];
        //[self.timeData removeLastObject];
        NSEnumerator *enumerator = [[NSEnumerator alloc]init];
        ICEQuote* iceQuote = [ICEQuote shareInstance];
    
        if([self.type isEqualToString: @"1min"]){
        //enumerator =[[app.iceQuote getKlineData:self.sCode type:@"minute"] objectEnumerator];
            @try{
                enumerator =[[iceQuote getKlineData:self.sCode type:@"minute"] objectEnumerator];
            }
            @catch(ICEException *s){
                NSLog(@"erro is %@",s);
            }
           
        }
       if([self.type isEqualToString: @"1day"]){
        //enumerator =[[app.iceQuote getKlineData:self.sCode type:@"day"] objectEnumerator];
          
           @try{
                 enumerator =[[iceQuote getKlineData:self.sCode type:@"day"] objectEnumerator];
           }
           @catch(ICEException *s){
               NSLog(@"erro is %@",s);
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
    

//    if([self.type isEqualToString: @"1day"]){
//        NSLog(@"kline   1day");
//        NSMutableArray *data = [NSMutableArray array];
//        NSEnumerator *enumerator = [self.KlineData objectEnumerator];
//        id obj = nil;
//        while (obj = [enumerator nextObject]){
//            WpQuoteServerDayKLineCodeInfo* kline = [[WpQuoteServerDayKLineCodeInfo alloc]init];
//            kline = obj;
//            if([_sCode isEqualToString: kline.sCode])
//            {
//                NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];
//                NSMutableString *dateString = [[NSMutableString alloc]initWithString:kline.sDate];
//                [dateString insertString:@"-" atIndex:4];
//                [dateString insertString:@"-" atIndex:7];
//                array[0] = dateString;
//                array[1] = @([kline.sOpenPrice floatValue]);
//                array[2] = @([kline.sHighPrice floatValue]);
//                array[3] = @([kline.sLowPrice floatValue]);
//                array[4] = @([kline.sLastPrice floatValue]);
//                array[5] = @([kline.sVolume floatValue]);
//                [data addObject:array];
//            }
//        }
//        NSMutableArray * newMarray = [NSMutableArray array];
//        NSEnumerator * enumerator1 = [data reverseObjectEnumerator];//倒序排列
//        id object;
//        while (object = [enumerator1 nextObject])
//        {
//            [newMarray addObject:object];
//        }
//        
//        Y_KLineGroupModel *groupModel = [Y_KLineGroupModel objectWithArray:newMarray];
//        self.groupModel = groupModel;
//        [self.modelsDict setObject:groupModel forKey:self.type];
//        [self.stockChartView reloadData];
//    }

  
}

#pragma --mark Getter方法 of Y_StockChartView
- (Y_StockChartView *)stockChartView
{
    if(!_stockChartView) {
        _stockChartView = [Y_StockChartView new];
        _stockChartView.itemModels = @[
                                       //[Y_StockChartViewItemModel itemModelWithTitle:@"指标" type:Y_StockChartcenterViewTypeOther],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"分时" type:Y_StockChartcenterViewTypeTimeLine],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"1分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"5分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"30分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"60分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"日线" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"周线" type:Y_StockChartcenterViewTypeKline],
                                       ];
        _stockChartView.dataSource = self;
        [self.view addSubview:_stockChartView];
        [_stockChartView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (IS_IPHONE_X) {
                make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 30, 0, 0));
            }
            else {
                make.top.equalTo(self.view);
                make.left.right.equalTo(self.view);
                //make.bottom.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-350);
                //make.edges.equalTo(self.view);
            }
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        tap.numberOfTapsRequired = 2;
        [_stockChartView addGestureRecognizer:tap];
    }
    return _stockChartView;
}

//横竖屏切换
- (void)dismiss
{
    NSLog(@"dismisss");
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    appdelegate.isEable = YES;//横屏
    Y_StockChartLandScapeViewController *stockChartVC = [Y_StockChartLandScapeViewController new];
    stockChartVC.sCode = _sCode;
    stockChartVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:stockChartVC animated:YES completion:nil];
 
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_loseLimtedTextField resignFirstResponder];
    [_winLimitedTextField resignFirstResponder];
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma --mark  keyboard delegate
- (void)keyboardWillHide:(NSNotification*)aNSNotification{
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }];
}
- (void)keyboardWillShow:(NSNotification*)aNSNotification{
    NSLog(@"willshow");
    NSValue *keyBoardBeginBounds=[[aNSNotification userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect  beginRect=[keyBoardBeginBounds CGRectValue];
    CGFloat deltaY=beginRect.size.height;
    [UIView animateWithDuration:0.25f animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, -deltaY, self.view.frame.size.width, self.view.frame.size.height)];
    }];
}

- (void)dealloc{
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"success" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
      [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
#pragma --mark Pickerview delegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 100;
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

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [NSString stringWithFormat:@"%ld",row+1];
}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"selected");
    //pickerView bringSubviewToFront:
    if(pickerView.tag == 1000 ){
        _loseLimtedTextField.text = [NSString stringWithFormat:@"%ld",row+1];
        //_loseLimit = [NSString stringWithFormat:@"%ld",row+1];
    }
    else{
        _winLimitedTextField.text = [NSString stringWithFormat:@"%ld",row+1];
        //_winLimit = [NSString stringWithFormat:@"%ld",row+1];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{

    UITextField *lossField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    if(pickerView.tag == 1000){
        lossField.backgroundColor = DropColor;
    }
    else{
        lossField.backgroundColor = RoseColor;
    }
    
    lossField.textAlignment = NSTextAlignmentCenter;
    //lossField.hidden = YES;
    lossField.text = [NSString stringWithFormat:@"%ld",row+1];
    lossField.textColor = [UIColor whiteColor];
    return lossField;

}
@end
