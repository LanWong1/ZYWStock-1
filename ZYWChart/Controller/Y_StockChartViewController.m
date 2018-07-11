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

@interface Y_StockChartViewController ()<Y_StockChartViewDataSource>

@property (nonatomic, strong) Y_StockChartView *stockChartView;

@property (nonatomic, strong) Y_KLineGroupModel *groupModel;

@property (nonatomic, copy) NSMutableDictionary <NSString*, Y_KLineGroupModel*> *modelsDict;


@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString* sCode;
@property (nonatomic, copy) WpQuoteServerDayKLineList* KlineData;

@end

@implementation Y_StockChartViewController

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
    NSLog(@"chart view will appear");
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor assistBackgroundColor];
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};//设置标题文字为白色
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;//设置状态栏文字为白色

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
   
    [super viewDidLoad];

     self.navigationItem.title = self.sCode;
    //self.navigationItem.leftBarButtonItem.style = ;
    // Do any additional setup after loading the view.
    self.currentIndex = -1;
    self.stockChartView.backgroundColor = [UIColor backgroundColor];//调用了getter方法[UIColor whiteColor]; // [UIColor backgroundColor];//调用了getter方法
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
            NSLog(@"kline 1min");
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
    //无数据 重新下载数据
    if(![self.modelsDict objectForKey:type])
    {
        NSLog(@"type = %@ data = %@",type, [self.modelsDict objectForKey:type]);
        [self reloadData];
    } else {
        return [self.modelsDict objectForKey:type].models;
    }
    return nil;
}

- (void)reloadData
{
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        //[app.iceQuote Connect2Quote];
        //self.timeData =
        [app.iceQuote getKlineData:self.sCode type:self.type];
        NSMutableArray *timeArray = [NSMutableArray array];
        NSMutableArray *data = [NSMutableArray array];
        //[self.timeData removeLastObject];
        NSEnumerator *enumerator = [[NSEnumerator alloc]init];
        if([self.type isEqualToString: @"1min"]){
        enumerator =[[app.iceQuote getKlineData:self.sCode type:@"minute"] objectEnumerator];
        }
       if([self.type isEqualToString: @"1day"]){
        enumerator =[[app.iceQuote getKlineData:self.sCode type:@"day"] objectEnumerator];
        }
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
                [timeArray addObject:array];
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
               [timeArray addObject:object];
           }
       }
        Y_KLineGroupModel *groupModel = [Y_KLineGroupModel objectWithArray:timeArray];
        self.groupModel = groupModel;
        [self.modelsDict setObject:groupModel forKey:self.type];
        [self.stockChartView reloadData];
    
//    
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
    NSLog(@"reload finish");
  
}
#pragma --mark Getter of Y_StockChartView
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
        
       // _stockChartView.backgroundColor = [UIColor orangeColor];
        _stockChartView.dataSource = self;
        [self.view addSubview:_stockChartView];
        [_stockChartView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (IS_IPHONE_X) {
                make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 30, 0, 0));
            } else {
                make.top.equalTo(self.view).offset(60);
                make.bottom.left.right.equalTo(self.view);
                //make.edges.equalTo(self.view);
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
    appdelegate.isEable = YES;
    
    Y_StockChartLandScapeViewController *stockChartVC = [Y_StockChartLandScapeViewController new];
    //stockChartVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:stockChartVC];
    //    [self.navigationController pushViewController:stockChartVC animated:YES];
    [self presentViewController:stockChartVC animated:NO completion:nil];

}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    //return UIStatusBarStyleDefault;
}
- (BOOL)shouldAutorotate
{
    return NO;
}
@end
