//
//  Y_StockChartLandScapeViewController.m
//  BTC-Kline
//
//  Created by zdqh on 2018/7/3.
//  Copyright © 2018 yate1996. All rights reserved.
//

#import "Y_StockChartLandScapeViewController.h"
#import "Masonry.h"
#import "Y_StockChartView.h"

//#import "NetWorking.h"
#import "Y_KLineGroupModel.h"
#import "UIColor+Y_StockChart.h"
#import "AppDelegate.h"
#import "Y_StockChartViewController.h"
#import "ICEQuote.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_MAX_LENGTH MAX(kScreenWidth,kScreenHeight)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

@interface Y_StockChartLandScapeViewController ()<Y_StockChartViewDataSource>


@property (nonatomic, strong) Y_StockChartView *stockChartView;
@property (nonatomic, strong) Y_KLineGroupModel *groupModel;
@property (nonatomic, copy) NSMutableDictionary <NSString*, Y_KLineGroupModel*> *modelsDict;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy)   NSString *type;
@property (nonatomic, strong) NSTimer *refreshTimer;

@property (nonatomic, assign) NSInteger currentTypeIndex;







@end

@implementation Y_StockChartLandScapeViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor backgroundColor];
    self.currentIndex = -1;
    self.stockChartView.backgroundColor = [UIColor backgroundColor];
    //注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeMinData:) name:@"changeMinDataNotity" object:nil];
    
}

-(void)changeMinData:(NSNotification*)notiy{
    
    NSLog(@"change MinData get notify+++++++++++++++");
    _MinData = notiy.userInfo[@"minData"];
    _fifteenMinsData = notiy.userInfo[@"fifteenMinData"];
    _fiveMinsData = notiy.userInfo[@"fiveMinData"];
    
}
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
            type = @"1min";
            _currentTypeIndex = 0;
        }
            break;
        case 1:
        {
            type = @"1min";
            _currentTypeIndex = 0;
        }
            break;
        case 2:
        {
            type = @"1min";
            _currentTypeIndex = 0;
        }
            break;
        case 3:
        {
            type = @"5min";
            _currentTypeIndex = 1;
        }
            break;
        case 4:
        {
            type = @"15min";
            _currentTypeIndex = 2;
        }
            break;
        case 5:
        {
            type = @"1month";
            _currentTypeIndex = 3;
        }
            break;
        case 6:
        {
            type = @"1day";
            _currentTypeIndex = 4;
        }
            break;
        case 7:
        {
            type = @"1week";
            _currentTypeIndex = 5;
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
            _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(reloadData) userInfo:nil repeats:YES];//每分钟刷新
        }
    }
    else{
        if(_refreshTimer != nil){
            [_refreshTimer invalidate];
            _refreshTimer = nil;
        }
    }
    if(![self.modelsDict objectForKey:type])
    {
        [self reloadData];
    } else {
        return [self.modelsDict objectForKey:type].models;
    }
    return nil;
}







- (void)reloadData
{

    NSMutableArray *data = [NSMutableArray array];

    switch (_currentTypeIndex) {
        case 0:
            [data addObjectsFromArray:_MinData];
            break;
        case 1:
            [data addObjectsFromArray:_fiveMinsData];
            break;
        case 2:
            [data addObjectsFromArray:_fifteenMinsData];
            break;
        case 3:
            [data addObjectsFromArray:_monthData];
            break;
        case 4:
            [data addObjectsFromArray:_dayData];
            break;
        case 5:
            [data addObjectsFromArray:_weekData];
            break;
        default:
            break;
    }
    self.groupModel  = [Y_KLineGroupModel objectWithArray:data];
    [self.modelsDict setObject:_groupModel forKey:self.type];//model 字典 键值编程 更新M_groupModel
    [self.stockChartView reloadData];
    [self.stockChartView.kLineView reDraw];//重绘kline
}
- (Y_StockChartView*)stockChartView
{
    
    
    NSLog(@"stockchartView");
    if(!_stockChartView) {

        _stockChartView = [Y_StockChartView new];
        _stockChartView.itemModels = @[
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"指标" type:Y_StockChartcenterViewTypeOther],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"分时" type:Y_StockChartcenterViewTypeTimeLine],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"1分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"5分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"15分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"月线" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"日线" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"周线" type:Y_StockChartcenterViewTypeKline],
                                       ];
       
        
        // _stockChartView.backgroundColor = [UIColor orangeColor];
        _stockChartView.dataSource = self;
        [self.view addSubview:_stockChartView];
        [_stockChartView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (IS_IPHONE_X) {
                make.top.left.right.equalTo(self.view);
                make.bottom.equalTo(self.view.mas_bottom).offset(-20);
            } else {
                make.top.equalTo(self.view);
                make.bottom.left.right.equalTo(self.view);
            }
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        tap.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:tap];
    }
    return _stockChartView;
}
- (void)dismiss
{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    appdelegate.isEable = NO;//非横屏
    if(_refreshTimer){
        [_refreshTimer invalidate];
    }

    if(_stockChartView){
        [_stockChartView removeFromSuperview];
    }
    [self dismissViewControllerAnimated:YES completion:nil ];
   
}
- (void)dealloc{
    NSLog(@"dealloc ++++++++++++++++");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeMinDataNotity" object:nil];
    
}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscape;
//}
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}


@end
