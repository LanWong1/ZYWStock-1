//
//  checkVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/26.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "checkVC.h"
#import "ICETool.h"
#import "AppDelegate.h"
#import "CheckOrderVC.h"
#import "checkHoldVC.h"
#import "CheckFundVC.h"
#import "BaseNavigationController.h"
#import "ICENpTrade.h"
#import "HoldDataModel.h"
#import "FundDataModel.h"
#import "OrderDataModel.h"
#define Y 5
@interface checkVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)  UIButton *QueryButton;
@property (nonatomic,strong)  UIButton *FundButton;
@property (nonatomic,strong)  UIButton *HoldButton;
@property (nonatomic,strong)  UIActivityIndicatorView *activeId;
@property (nonatomic) NSMutableArray* Msg;
@property (nonatomic) NpTradeAPIServerCallbackReceiverI* npTradeAPIServerCallbackReceiverI;
@property (nonatomic) WpTradeAPIServerCallbackReceiverI* wpTradeAPIServerCallbackReceiverI;
@property (nonatomic) CheckFundVC* checkFundVC;
@property (nonatomic,strong)  UISegmentedControl *segment;
@property (nonatomic,strong)  NSMutableArray<__kindof HoldDataModel*> *modleHoldArray;
@property (nonatomic,strong)  NSMutableArray<__kindof FundDataModel*> *modleFundArray;
@property (nonatomic,strong)  NSMutableArray<__kindof OrderDataModel*> *modleOrderArray;
@property (nonatomic) int segmentIndex;
@property (nonatomic,strong)  UITableView    *tableView;
@property (nonatomic,strong)  UIView    *titleView;
@property (nonatomic, retain) UIRefreshControl * refreshControl;

@end

@implementation checkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"账户";
    //self.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 120, DEVICE_WIDTH, 40)];
    [self addSementView];
    [self addTitleView];
    [self addActiveId];
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
#if NpTradeTest
    [app.iceNpTrade queryHold:app.strCmd];
#else
    [app.iceTool queryHold:app.strCmd];
#endif
    [self.activeId startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addHoldView) userInfo:nil repeats:NO];
    // Do any additional setup after loading the view.
}
- (void)addTitleView{
    //self.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 120, DEVICE_WIDTH, 40)];
    self.titleView = [[UIView alloc]init];
    //self.titleView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segment.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(40));
    }];
}
#pragma -mark 下拉刷新
- (void)addRefreshControl{
    _refreshControl = [[UIRefreshControl alloc]init];
    _refreshControl.tintColor = [UIColor redColor];
    _refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [_refreshControl addTarget:self action:@selector(refreshControlAction) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
}
- (void)refreshControlAction{
    [self.tableView removeFromSuperview];
    if(self.refreshControl.refreshing){
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
        switch (self.segmentIndex) {
            case 0:
                [self queryOrder];
                break;
            case 1:
                [self queryHold];
                break;
            case 2:
                [self queryFund];
                break;
            default:
                break;
        }
  
        [self.refreshControl endRefreshing];
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addActiveId{
    self.activeId = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeId.center = CGPointMake(self.view.centerX ,self.view.centerY);
    [self.view addSubview:self.activeId];
}
- (void)addSementView{
    NSArray *titleArray = [[NSArray alloc]initWithObjects:@"委托",@"持仓",@"资金", nil];
    self.segment = [[UISegmentedControl alloc]initWithItems:titleArray];
    self.segment.selectedSegmentIndex = 1;//默认显示委托的数据
    self.segment.tintColor = DropColor;
    self.segment.frame = CGRectMake(0, 65, DEVICE_WIDTH, 40);
    [self.view addSubview:self.segment];
    [self.segment addTarget:self action:@selector(touchSegment:) forControlEvents:UIControlEventValueChanged];
}
- (void)addOrderTitle{

//    [self.titleView removeFromSuperview];
//    [self addTitleView];
    for(UIView* view in [self.titleView subviews]){
        [view removeFromSuperview];
    }
    [self.titleView addSubview: [self addLableWithName:@"商品代码" PositonX:0 PositionY:Y Type:0]];
    [self.titleView addSubview: [self addLableWithName:@"合约代码" PositonX:70 PositionY:Y Type:0]];
    [self.titleView addSubview: [self addLableWithName:@"开仓平仓" PositonX:140 PositionY:Y Type:0]];
    [self.titleView addSubview: [self addLableWithName:@"买卖方向" PositonX:210 PositionY:Y Type:0]];
    [self.titleView addSubview: [self addLableWithName:@"成交数量" PositonX:280 PositionY:Y Type:0]];
    [self.titleView addSubview: [self addLableWithName:@"委托价格" PositonX:70*5 PositionY:Y Type:0]];
    //[self.view addSubview:self.titleView];

}
- (void)addOrderView{
    [self.activeId stopAnimating];
    [self getMSg];
    [self addOrderTitle];
    self.modleOrderArray = [NSMutableArray array];
    NSEnumerator* enumerator = [self.Msg objectEnumerator];
    id obj = nil;
    while(obj = [enumerator nextObject]){
        NSArray * arry = obj;
        OrderDataModel *M = [[OrderDataModel alloc]init];
        M.CommodityNo = arry[6];
        M.ContractNo  = arry[7];
        M.OffSet  = arry[14];
        M.Direction   = arry[13];
        M.MatchVol    = arry[38];
        M.OrderPrice  = arry[16];
        [self.modleOrderArray addObject:M];
    }
    if([self.modleOrderArray count] == 0){
        [self setAlertWithMessage:@"无委托"];
    }
    self.segmentIndex = 0;
    [self addTableView];
}
- (void)addHoldTitle{

//    [self.titleView removeFromSuperview];
//    [self addTitleView];
    
    for(UIView* view in [self.titleView subviews]){
        [view removeFromSuperview];
    }
    [self.titleView addSubview:[self addLableWithName:@"商品编号" PositonX:0 PositionY:Y Type:0]];
    [self.titleView addSubview:[self addLableWithName:@"合约号"  PositonX:70 PositionY:Y Type:0]];
    [self.titleView addSubview:[self addLableWithName:@"买卖方向" PositonX:140 PositionY:Y Type:0]];
    [self.titleView addSubview:[self addLableWithName:@"持仓量" PositonX:210 PositionY:Y Type:0]];
    [self.titleView addSubview:[self addLableWithName:@"保证金" PositonX:280 PositionY:Y Type:0]];
    [self.titleView addSubview:[self addLableWithName:@"昨结算价" PositonX:70*5 PositionY:Y Type:0]];
    //[self.view addSubview:self.titleView];
}
- (void)addHoldView{
    [self.activeId stopAnimating];
    [self getMSg];
    [self addHoldTitle];
    self.modleHoldArray = [NSMutableArray array];
    NSEnumerator* enumerator = [self.Msg objectEnumerator];
    id obj = nil;
    while(obj = [enumerator nextObject]){
        NSArray * arry = obj;
        HoldDataModel *M = [[HoldDataModel alloc]init];
        M.CommodityNo = arry[7];
        M.ContractNo = arry[8];
        M.Direct = arry[9];
        M.TradeVol = arry[12];
        M.YSettlePrice = arry[13];
        M.Deposit = arry[17];
        [self.modleHoldArray addObject:M];
    }
    if([self.modleHoldArray count] == 0){
        [self setAlertWithMessage:@"无持仓"];
    }
    self.segmentIndex = 1;
    [self addTableView];
}
- (void)addFunTitle{
    
//    [self.titleView removeFromSuperview];
//    [self addTitleView];
    for(UIView* view in [self.titleView subviews]){
        [view removeFromSuperview];
    }
    [self.titleView addSubview:[self addLableWithName:@"货币编号" PositonX:0 PositionY:Y Type:0]];
    [self.titleView addSubview:[self addLableWithName:@"今资金"  PositonX:70 PositionY:Y Type:0]];
    [self.titleView addSubview:[self addLableWithName:@"今权益" PositonX:140 PositionY:Y Type:0]];
    [self.titleView addSubview:[self addLableWithName:@"今可提" PositonX:210 PositionY:Y Type:0]];
    [self.titleView addSubview:[self addLableWithName:@"风险率" PositonX:280 PositionY:Y Type:0]];
    [self.titleView addSubview:[self addLableWithName:@"账户市值" PositonX:70*5 PositionY:Y Type:0]];
}


- (void)addFundView{
    [self.activeId stopAnimating];
    [self getMSg];
    [self addFunTitle];
    self.modleFundArray = [NSMutableArray array];
    NSEnumerator* enumerator = [self.Msg objectEnumerator];
    id obj = nil;
    while(obj = [enumerator nextObject]){
        NSArray * arry = obj;
        FundDataModel *M = [[FundDataModel alloc]init];
        M.CurrencyNo = arry[6];
        M.TMoney     = arry[37];
        M.TBalance   = arry[38];
        M.TCanCashOut = arry[39];
        M.RiskRate   = arry[40];
        M.AccountMarketValue = arry[41];
        [self.modleFundArray addObject:M];
    }
    if([self.modleFundArray count] == 1){
        [self setAlertWithMessage:@"无资金"];
    }
    self.segmentIndex = 2;
    [self addTableView];
}

- (void)setAlertWithMessage:(NSString*)msg{
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"警告"
                                                                 message:msg
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
//选中segment
-(void)touchSegment:(UISegmentedControl*)segment{
    [self.tableView removeFromSuperview];//移除tableview 重新创建
    switch(segment.selectedSegmentIndex){
        case 0:
            NSLog(@"委托");
            if(_modleOrderArray != nil){
                self.segmentIndex = 0;
                [self addOrderTitle];
                [self addTableView];
            }
            else{
                [self queryOrder];
            }
            break;
        case 1:
            NSLog(@"持仓");
            if(_modleHoldArray != nil){
                self.segmentIndex = 1;
                [self addHoldTitle];
                [self addTableView];
            }
            else{
                [self queryHold];
            }
            break;
        case 2:
            NSLog(@"资金");
            if(_modleFundArray != nil){
                self.segmentIndex = 2;
                [self addFunTitle];
                [self addTableView];
            }
            else{
                [self queryFund];
            }
            break;
        default:
            break;
    }
   
}

- (void)queryOrder{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
#if NpTradeTest
    [app.iceNpTrade queryOrder:app.strCmd];
#else
    [app.iceTool queryOrder:app.strCmd];
#endif
    [self.activeId startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addOrderView) userInfo:nil repeats:NO];
}

- (void)queryHold{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
#if NpTradeTest
    [app.iceNpTrade queryHold:app.strCmd];
#else
    [app.iceTool queryHold:app.strCmd];
#endif
    [self.activeId startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addHoldView) userInfo:nil repeats:NO];
}
- (void)queryFund{
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
#if NpTradeTest
    [app.iceNpTrade queryFund:app.strCmd];
#else
    [app.iceTool queryFund:app.strCmd];
#endif
    [self.activeId startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addFundView) userInfo:nil repeats:NO];
}

- (UILabel*)addLableWithName:(NSString*)name PositonX:(CGFloat)x PositionY:(CGFloat)y Type:(int)type {
    UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(x, y, 70, 40)];
    lable.text = name;
    lable.textAlignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont systemFontOfSize:13];
    [lable setFont:font];
    if(type==0){
        lable.backgroundColor = DropColor;
        [self.view addSubview:lable];
    }
    else{
        lable.backgroundColor = [UIColor whiteColor];
    }
    return lable;
}




- (void)getMSg{
    self.Msg = [NSMutableArray array];
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
#if NpTradeTest
    NSEnumerator *enumerator = [[app.npTradeAPIServerCallbackReceiverI messageForBuyVC] objectEnumerator];
#else
    NSEnumerator *enumerator = [[app.wpTradeAPIServerCallbackReceiverI messageForBuyVC] objectEnumerator];
#endif
    //
    id obj = nil;
    while (obj = [enumerator nextObject]){
        NSMutableString *Message = [[NSMutableString alloc]initWithCapacity:0];
        Message = obj;
        NSArray* arry=[Message componentsSeparatedByString:@"="];
        [self.Msg addObject:arry];
    }
}





- (void)addTableView{

    self->_tableView = [[UITableView alloc] init];
    self->_tableView.delegate = self;
    self->_tableView.dataSource = self;
    [self.view addSubview:self->_tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(DEVICE_HEIGHT-120));
    }];
    [self addRefreshControl];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch(self.segmentIndex)
    {
        case 0:
            count =  [self.modleOrderArray count]-1;
            break;
        case 1:
            count = [self.modleHoldArray count]-1;
            break;
        case 2:
            count = [self.modleFundArray count]-1;
            break;
        default:
            NSLog(@"ggggg");
    }
    NSLog(@"cout==%ld",(long)count);
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"dddddd");
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(self.segmentIndex == 0){
        NSString* CommodityNo = [self.modleOrderArray objectAtIndex:indexPath.row].CommodityNo;
        NSString* ContractNo = [self.modleOrderArray objectAtIndex:indexPath.row].ContractNo;
        NSString* OffSet = [self.modleOrderArray objectAtIndex:indexPath.row].OffSet;
        NSString* Direction = [self.modleOrderArray objectAtIndex:indexPath.row].Direction;
        NSString* MatchVol = [self.modleOrderArray objectAtIndex:indexPath.row].MatchVol;
        NSString* OrderPrice = [self.modleOrderArray objectAtIndex:indexPath.row].OrderPrice;
        [cell addSubview: [self addLableWithName:CommodityNo PositonX:0 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:ContractNo PositonX:70 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:OffSet PositonX:140 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:Direction PositonX:210 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:MatchVol PositonX:280 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:OrderPrice PositonX:350 PositionY:5 Type:1]];
    }
    else if(self.segmentIndex == 1){
        NSString* CommodityNo = [self.modleHoldArray objectAtIndex:indexPath.row].CommodityNo;
        NSString* ContractNo = [self.modleHoldArray objectAtIndex:indexPath.row].ContractNo;
        NSString* Direct = [self.modleHoldArray objectAtIndex:indexPath.row].Direct;
        NSString* TradeVol = [self.modleHoldArray objectAtIndex:indexPath.row].TradeVol;
        NSString* Deposit = [self.modleHoldArray objectAtIndex:indexPath.row].Deposit;
        NSString* YSettlePrice = [self.modleHoldArray objectAtIndex:indexPath.row].YSettlePrice;
        
        [cell addSubview: [self addLableWithName:CommodityNo PositonX:0 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:ContractNo PositonX:70 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:Direct PositonX:140 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:TradeVol PositonX:210 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:Deposit PositonX:280 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:YSettlePrice PositonX:350 PositionY:5 Type:1]];
    }
    
    else if (self.segmentIndex == 2){
        NSString* currencyCode = [self.modleFundArray objectAtIndex:indexPath.row].CurrencyNo;
        NSString* Tmoney = [self.modleFundArray objectAtIndex:indexPath.row].TMoney;
        NSString* Tbalance = [self.modleFundArray objectAtIndex:indexPath.row].TBalance;
        NSString* TcanCashOut = [self.modleFundArray objectAtIndex:indexPath.row].TCanCashOut;
        NSString* riskRate = [self.modleFundArray objectAtIndex:indexPath.row].RiskRate;
        NSString* accountMarketValue = [self.modleFundArray objectAtIndex:indexPath.row].AccountMarketValue;
        [cell addSubview: [self addLableWithName:currencyCode PositonX:0 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:Tmoney PositonX:70 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:Tbalance PositonX:140 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:TcanCashOut PositonX:210 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:riskRate PositonX:280 PositionY:5 Type:1]];
        [cell addSubview:[self addLableWithName:accountMarketValue PositonX:350 PositionY:5 Type:1]];
    }
    return cell;
}
- (void)viewDidAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
