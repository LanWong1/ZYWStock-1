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
//#import "BaseNavigationController.h"
#import "ICENpTrade.h"
#import "HoldDataModel.h"
#import "FundDataModel.h"
#import "OrderDataModel.h"
#import "BaoBiaoItem.h"
#import "BaoBiaoItemHeader.h"
#import "BaoBiaoLayout.h"
#define Y 5
@interface checkVC ()<UICollectionViewDataSource,UICollectionViewDelegate>

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
@property (nonatomic,strong)  UITableView *tableView;
@property (nonatomic,strong)  UIView      *titleView;
@property (nonatomic, retain) UIRefreshControl * refreshControl;





@property (nonatomic, strong) NSMutableArray *checkItems;
@property (nonatomic,strong) NSMutableArray *checkItemsTitle;





@property (nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong)BaoBiaoLayout *layout;
@property (nonatomic,assign) int mBMaxWith;






@end

@implementation checkVC
- (void)viewDidAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];//导航栏背景色
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];//设置返回字体颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;//设置状态时间文字为
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"账户";
    self.mBMaxWith = DEVICE_WIDTH;
    self.checkItems = [NSMutableArray array];
    [self addSementView];
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

#pragma mark 添加collection view
-(void)addCollectionView{
 
    [self setCollectionViewLayout];
    if(!self.collectionView){
        self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:self.layout];
        [self.collectionView setDirectionalLockEnabled:YES];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self.collectionView registerNib:[UINib nibWithNibName:@"BaoBiaoItem" bundle:nil] forCellWithReuseIdentifier:@"BaoBiaoItem"];//cell
        [self.collectionView registerNib:[UINib nibWithNibName:@"BaoBiaoItemHeader" bundle:nil] forCellWithReuseIdentifier:@"BaoBiaoItemHeader"];//头部
        //self.collectionView.backgroundView.backgroundColor = [UIColor whiteColor];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.segment.mas_bottom);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.height.equalTo(self.view);
        }];
    }
    [self.layout reset];
    [self updateMyList];
}
//更新数据
-(void)updateMyList{
    
    if (self.checkItems == nil || self.checkItems.count == 0) {
        self.collectionView.hidden = YES; //无数据 隐藏表格
        return;
    }
    self.collectionView.hidden = NO;//显示
    [self.collectionView reloadData];
}
//设置layout
- (void)setCollectionViewLayout{
    //layout 设置
    if(!self.layout){
        self.layout = [[BaoBiaoLayout alloc]init];
        self.collectionView.collectionViewLayout = self.layout;
    }
    [self.layout reset];//清空设置
    if (IS_IPHONE_X) {
        [self.layout setItemHeight:40];
    }else{
        [self.layout setItemHeight:30];//高度
    }
    NSArray *array = self.checkItems[0];//第一行数据
    [self.layout setColumnWidths :(int)array.count withMaxWidth:_mBMaxWith];
}

- (void)addActiveId{
    self.activeId = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeId.center = CGPointMake(self.view.centerX ,self.view.centerY);
    [self.view addSubview:self.activeId];
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
    [self.collectionView removeFromSuperview];
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






- (void)addOrderView{
    if(self.checkItems){
        [self.checkItems removeAllObjects];
    }
    [self.activeId stopAnimating];
    [self getMSg];
    //[self addOrderTitle];
    NSMutableArray *checkItems = [NSMutableArray arrayWithObjects:@"合约名称",@"状态",@"开平",@"委托价",@"委托量",@"已成交",@"已撤单",@"委托时间", nil];
    [self.checkItems addObject:checkItems];
    self.modleOrderArray = [NSMutableArray array];
    NSEnumerator* enumerator = [self.Msg objectEnumerator];
    id obj = nil;
    while(obj = [enumerator nextObject]){
        NSMutableArray *arryTemp = [NSMutableArray array];
        NSArray * arry = obj;
        OrderDataModel *M = [[OrderDataModel alloc]init];
        M.CommodityNo = arry[6];
        M.ContractNo  = arry[7];
        M.OffSet      = arry[14];
        M.Direction   = arry[13];
        M.MatchVol    = arry[38];
        M.OrderPrice  = arry[16];
        [arryTemp addObject:arry[6]];
        [arryTemp addObject:arry[7]];
        [arryTemp addObject:arry[14]];
        [arryTemp addObject:arry[13]];
        [arryTemp addObject:arry[38]];
        [arryTemp addObject:arry[16]];
        [self.checkItems addObject:arryTemp];
        [self.modleOrderArray addObject:M];
    }
    if([self.modleOrderArray count] == 0){
        [self setAlertWithMessage:@"无委托"];
    }
    [self addCollectionView];
    self.segmentIndex = 0;
  
}


- (void)addHoldView{
    
    if(self.checkItems){
        [self.checkItems removeAllObjects];
    }
    NSMutableArray *checkItems = [NSMutableArray arrayWithObjects:@"合约名称",@"多空",@"总仓",@"可用",@"开仓均价",@"逐笔盈亏", nil];
    [self.checkItems addObject:checkItems];
    [self.activeId stopAnimating];
    [self getMSg];
    //[self addHoldTitle];
    self.modleHoldArray = [NSMutableArray array];
    NSEnumerator* enumerator = [self.Msg objectEnumerator];
    id obj = nil;
    while(obj = [enumerator nextObject]){
        NSMutableArray *arryTemp = [NSMutableArray array];
        NSArray * arry = obj;
        HoldDataModel *M = [[HoldDataModel alloc]init];
        M.CommodityNo = arry[7];
        M.ContractNo = arry[8];
        M.Direct = arry[9];
        M.TradeVol = arry[12];
        M.YSettlePrice = arry[13];
        M.Deposit = arry[17];
        [arryTemp addObject:arry[7]];
        [arryTemp addObject:arry[8]];
        [arryTemp addObject:arry[9]];
        [arryTemp addObject:arry[12]];
        [arryTemp addObject:arry[13]];
        [arryTemp addObject:arry[17]];
        [self.checkItems addObject:arryTemp];
        [self.modleHoldArray addObject:M];
    }
    if([self.modleHoldArray count] == 0){
        [self setAlertWithMessage:@"无持仓"];
    }
    
    [self addCollectionView];
   // [self updateMyList:@[@4,@8,@8,@8,@8]];
    self.segmentIndex = 1;
}








- (void)addFundView{
    if(self.checkItems){
        [self.checkItems removeAllObjects];
    }
    NSMutableArray *checkItems = [NSMutableArray arrayWithObjects:@"可用资金",@"动态权益",@"持仓盈亏",@"平仓盈亏",@"静态权益",@"保证金", @"冻结资金",nil];
    [self.checkItems addObject:checkItems];
    [self.activeId stopAnimating];
    [self getMSg];
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
    [self addCollectionView];
    self.segmentIndex = 2;
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


#pragma --mark  segmentView 相关

- (void)addSementView{
    NSArray *titleArray = [[NSArray alloc]initWithObjects:@"委托",@"持仓",@"资金",@"挂单",@"成交", nil];
    self.segment = [[UISegmentedControl alloc]initWithItems:titleArray];
    self.segment.selectedSegmentIndex = 1;//默认显示委托的数据
    //self.segment.tintColor = DropColor;
    [self.segment setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    
    if(IS_IPHONE_X){
        self.segment.frame = CGRectMake(0, 65+24, DEVICE_WIDTH, 40);
    }
    else{
        self.segment.frame = CGRectMake(0, 65, DEVICE_WIDTH, 40);
    }
    [self.view addSubview:self.segment];
    [self.segment addTarget:self action:@selector(touchSegment:) forControlEvents:UIControlEventValueChanged];
}
-(void)touchSegment:(UISegmentedControl*)segment{
 
    switch(segment.selectedSegmentIndex){
        case 0:
            NSLog(@"委托");
            [self queryOrder];
            break;
        case 1:
            NSLog(@"持仓");
            [self queryHold];
            break;
        case 2:

            [self queryFund];
            break;
        case 3:
            [self checkPendingOrder];
            NSLog(@"挂单");
            break;
        case 4:
            [self checkDealDown];
            NSLog(@"成交");
            
            break;
        default:
            break;
    }
}


- (void)checkPendingOrder{
    if(self.checkItems){
        [self.checkItems removeAllObjects];
    }
    NSMutableArray *checkItems = [NSMutableArray arrayWithObjects:@"合约名称",@"开平",@"委托价",@"委托量",@"挂单量",nil];
    [self.checkItems addObject:checkItems];
    [self.activeId stopAnimating];
    [self addCollectionView];
    self.segmentIndex = 3;
}

- (void)checkDealDown{
    if(self.checkItems){
        [self.checkItems removeAllObjects];
    }
    NSMutableArray *checkItems = [NSMutableArray arrayWithObjects:@"合约名称",@"开平",@"成交价",@"成交量",@"成交时间",nil];
    [self.checkItems addObject:checkItems];
    [self.activeId stopAnimating];
    [self addCollectionView];
    self.segmentIndex = 4;
}
#pragma --mark 获取数据
- (void)queryOrder{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ICEQuote *quote = [ICEQuote shareInstance];
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






#pragma --mark  collectionView controller 代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    NSLog(@"hahahahahah");
    return self.checkItems.count;//返回 报表 共有多少行
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSArray *array = self.checkItems[section];
    return array.count;//返回 报表 每行有多少列
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {//整个报表最上面的那行
        BaoBiaoItemHeader *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BaoBiaoItemHeader" forIndexPath:indexPath ];
        NSArray *array = self.checkItems[indexPath.section];
        [cell setMessage:array[indexPath.row]];
        return cell;
    }else{//其他行
        BaoBiaoItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BaoBiaoItem" forIndexPath:indexPath];
        
        //设置单元行颜色的间隔的控制
        if (indexPath.section % 2 == 0) {
            [cell setBackgroundColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1]];
        }else{
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
        NSArray *array = self.checkItems[indexPath.section];
        [cell setMessage:array[indexPath.row]];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"section = %ld  item = %ld",(long)indexPath.section,(long)indexPath.row);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
