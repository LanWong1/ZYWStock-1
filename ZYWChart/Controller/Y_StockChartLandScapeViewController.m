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
        }
            break;
        case 1:
        {
            type = @"1min";
        }
            break;
        case 2:
        {
            type = @"1min";
        }
            break;
        case 3:
        {
            type = @"5min";
        }
            break;
        case 4:
        {
            type = @"30min";
        }
            break;
        case 5:
        {
            type = @"1hour";
        }
            break;
        case 6:
        {
            type = @"1day";
        }
            break;
        case 7:
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
    
    NSMutableArray *dataArray = [NSMutableArray array];
    NSMutableArray *data = [NSMutableArray array];
    NSEnumerator *enumerator = [[NSEnumerator alloc]init];
    ICEQuote* iceQuote = [ICEQuote shareInstance];
    if([self.type isEqualToString: @"1min"]){
        @try{
            NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@" ,self.sCode,@"=",iceQuote.userID];
            NSMutableArray *arrayTemp = [iceQuote getKlineData:strCmd type:@"minute"];
            //NSMutableArray *arrayTemp = [iceQuote getKlineData:self.sCode type:@"minute"];
            if(arrayTemp.count == 0){
                NSLog(@"分钟线 ++++++++++++");
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
            NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@" ,self.sCode,@"=",iceQuote.userID];
            NSMutableArray *arrayTemp = [iceQuote getKlineData:strCmd type:@"day"];
            enumerator =[arrayTemp objectEnumerator];
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
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"30分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"60分" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"日线" type:Y_StockChartcenterViewTypeKline],
                                       [Y_StockChartViewItemModel itemModelWithTitle:@"周线" type:Y_StockChartcenterViewTypeKline],
                                       ];
       
        
        // _stockChartView.backgroundColor = [UIColor orangeColor];
        _stockChartView.dataSource = self;
        [self.view addSubview:_stockChartView];
        [_stockChartView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (IS_IPHONE_X) {
//               make.top.equalTo(self.view);
//               make.bottom.right.left.equalTo(self.view);
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
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscape;
//}
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}


@end
