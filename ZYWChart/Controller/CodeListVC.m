//
//  HistoryVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/5/29.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "CodeListVC.h"
#import "CandleLineVC.h"
#import <objc/Ice.h>
#import <objc/Glacier2.h>
#import <WpQuote.h>
#include "TimeLineVC.h"
#import "ICEQuote.h"
#import "AppDelegate.h"



@interface CodeListVC ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating, UISearchControllerDelegate>
@property (nonatomic,strong)  UISearchController *searchController;
@property (nonatomic, retain) UIRefreshControl * refreshControl;
@property (nonatomic, copy)   NSString *filterString;
@property (nonatomic,strong)  UITableView    *tableView;
@property (nonatomic,strong)    NSMutableArray *titlesArray;
@property (nonatomic,strong)    NSMutableArray *allTitlesArray;
@property (nonatomic,strong)  UISearchBar *search;

@property (nonatomic,copy)    NSArray* zjsResult;
@property (nonatomic,copy)    NSArray* zssResult;
@property (nonatomic,copy)    NSArray* dssResult;
@property (nonatomic,copy)    NSArray* sqsResult;

@property (nonatomic,copy)    NSArray* searchResult;
@property (nonatomic,copy)    NSMutableArray* TimeData;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList;
@property (nonatomic,strong) NSMutableArray *KlineListAll;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList0;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList1;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList2;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList3;
@property (nonatomic)        ICEInt iRet;
@property (nonatomic) id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id session;
@property (nonatomic)        ICEInt refreshFlag;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIActivityIndicatorView *activeId;
@property (nonatomic,strong) UIButton *btn;
@property (nonatomic,strong) UIButton *searchBtn;
@property (nonatomic) ICEQuote* iceQuote;
@property (nonatomic,strong) UIView *searchView;
@property (nonatomic,strong) UISegmentedControl *segment;
@property (nonatomic,strong) NSString *sExchangeID;//交易所
@property (nonatomic) int segmentIndex;//
@property (nonatomic, strong) dispatch_source_t timer;
//@property (nonatomic,strong) TimeLineVC *timeLineVC;

@property (nonatomic) id<WpQuoteServerCallbackReceiverPrx> twowayR;
@end


@implementation CodeListVC


@synthesize communicator;
@synthesize session;
@synthesize router;
@synthesize twowayR;
@synthesize KlineList;
@synthesize WpQuoteServerclientApiPrx;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allTitlesArray = [[NSMutableArray alloc]init];
     self.KlineListAll = [[NSMutableArray alloc]init];
    self.navigationItem.title = @"合约代码";
    [self addSearchButton];
    [self addSementView];
    self.sExchangeID = @"CFFEX";//默认为中金所
    self.segmentIndex = 0;
    [self GetData];
    
    // Do any additional setup after loading the view.
}


//添加放大镜
- (void)addSearchButton{
    UIImage* searchImgNormal = [UIImage imageNamed:@"searchNormal.png"];
    UIImage* searchImgSelected = [UIImage imageNamed:@"searchSelected.png"];
    self.searchBtn = [[UIButton alloc]init];
    [self.searchBtn setImage:searchImgNormal forState:UIControlStateNormal];
    [self.searchBtn setImage:searchImgSelected forState:UIControlStateHighlighted];
    [self.searchBtn addTarget:self action:@selector(addSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc]initWithCustomView:self.searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtn;
}

#pragma -mark   获取数据
//conncet to server
- (void) GetData{
    [self.activeId startAnimating];
    //[self getData];
    //开线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        @try
        {
            AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            app.iceQuote = [[ICEQuote alloc]init];
            app.wpQuoteServerCallbackReceiverI =  [app.iceQuote Connect2Quote];
            [app.iceQuote initiateCallback:app.strAcc];
            [app.iceQuote Login:app.strCmd];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.activeId stopAnimating];
                [self.label removeFromSuperview];
                [self setHeartbeat];
                [self getData];
            });
        }
        @catch(GLACIER2CannotCreateSessionException* ex)
        {
            NSString* s = [NSString stringWithFormat:@"Session creation failed: %@", ex.reason_];
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSLog(@"%@",s);
            });
        }
        @catch(GLACIER2PermissionDeniedException* ex)
        {
            NSString* s = [NSString stringWithFormat:@"Login failed: %@", ex.reason_];
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSLog(@"%@",s);
            });
        }
        @catch(ICEEndpointParseException* ex)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error parsing config"
                                                                           message:ex.reason
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            [self.communicator destroy];
            self.communicator = nil;
            return;
        }
    });
}


- (void)setHeartbeat{
    // 创建GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 3 * NSEC_PER_SEC, 0); //每3秒执行
    // 事件回调
    //NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@%@%@",self.UserNameTextField.text,@"=",self.strUserId,@"=",self.PassWordTextField.text];
    
    dispatch_source_set_event_handler(_timer, ^{
        int iRet = -2;
        @try{
            AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            iRet = [app.iceTool HeartBeat:app.strCmd];
        }
        @catch(ICEException* s){
            NSLog(@"heart beat fail");
        }
        if(iRet == -2){
            //重新连接
            dispatch_source_cancel(self->_timer);
            [self GetData];
        }
    });
    // 开启定时器
    dispatch_resume(_timer);
}

//getData
- (void)getData{
    //[self getKline];
    //[self addTableView];
    if(self.refreshFlag!= 1)
    {
        [self addActiveId];
        [self addLabel];
        [self.activeId startAnimating];
    }
    self.TimeData = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [self getKline];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.activeId stopAnimating];
            [self.activeId removeFromSuperview];
            [self.label removeFromSuperview];
             [self loadData];
            [self addTableView];
            [self addRefreshControl];
        });
    });
}


//GetDayKLine
- (void)getKline
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.iceQuote Connect2Quote];
    self.KlineList = [app.iceQuote GetDayKline:self.sExchangeID];
    
//    NSString* cmdType = @"CTP,";
//    cmdType =  [cmdType stringByAppendingString:app.strAcc];
//    [app.iceQuote SubscribeQuote:cmdType strCmd:@"c1809"];
    
}

//get titlesArray
- (void)loadData{
    NSLog(@"load data");
    NSMutableArray* sCodeAll = [[NSMutableArray alloc]init];
    _titlesArray = [[NSMutableArray alloc]init];
    //_searchResult = [[NSMutableArray alloc]init];
    NSEnumerator *enumerator = [self.KlineList objectEnumerator];
    id obj = nil;
    while (obj = [enumerator nextObject]){
        WpQuoteServerDayKLineCodeInfo* kline = [[WpQuoteServerDayKLineCodeInfo alloc]init];
        kline = obj;
        [self.KlineListAll addObject:kline];//将所有数据保存到klinelistall
        [sCodeAll addObject:kline.sCode];
    }
    [_titlesArray addObject:sCodeAll[0]];
    for(int i=1;i<sCodeAll.count;i++){
        if(![sCodeAll[i] isEqual:sCodeAll[i-1]]){
            [_titlesArray addObject:sCodeAll[i]];
        }
    }
    switch (_segmentIndex) {
        case 0:
            _KlineList0 = self.KlineList;
            _zjsResult = _titlesArray;
            break;
        case 1:
            _KlineList1 = self.KlineList;
            _zssResult = _titlesArray;
            break;
        case 2:
            _KlineList2 = self.KlineList;
            _dssResult = _titlesArray;
            break;
        case 3:
            _KlineList3 = self.KlineList;
            _sqsResult = _titlesArray;
        default:
            break;
    }

    for(int j = 0;j<_titlesArray.count;j++){
        [self.allTitlesArray addObject:_titlesArray[j]];
    }
    _searchResult = _titlesArray;
    
}

#pragma -mark 添加视图
- (void)addActiveId{
    self.activeId = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeId.center = CGPointMake(self.view.centerX ,self.view.centerY+200);
    [self.view addSubview:self.activeId];
}
//"please wait"
- (void)addLabel{
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.centerX-40, self.view.centerY-200, 80, 20)];
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.textAlignment  = NSTextAlignmentCenter;
    self.label.text = @"Please Wait";
    [self.view addSubview:self.label];
}
//添加searchbar
- (void)addSearch{
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.delegate = self;
    self.search = self.searchController.searchBar;
    self.search.backgroundColor = [UIColor whiteColor];
    [self.search sizeToFit];
    self.definesPresentationContext = YES;
    self.extendedLayoutIncludesOpaqueBars  = YES;
    _search.showsCancelButton = YES;
    _search.placeholder = @"search code";
    //消除背景色
    for(UIView *View in self.searchController.searchBar.subviews){
        if([View isKindOfClass:NSClassFromString(@"UIView")]&&View.subviews.count>0){
            [[View.subviews objectAtIndex:0]removeFromSuperview];
            break;
        }
    }
    self.searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 55, DEVICE_WIDTH, self.searchController.searchBar.frame.size.height)];
    [self.searchView addSubview:self.search];
    [self.view addSubview:self.searchView];
}
//tableview
- (void)addTableView{
    self->_tableView = [[UITableView alloc] init];
    self->_tableView.delegate = self;
    self->_tableView.dataSource = self;
    [self.view addSubview:self->_tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segment.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(DEVICE_HEIGHT-120));
    }];
}
#pragma -mark 添加segment
//添加segment
- (void)addSementView{
    NSArray *titleArray = [[NSArray alloc]initWithObjects:@"中金所",@"郑商所",@"大商所",@"上期所", nil];
    self.segment = [[UISegmentedControl alloc]initWithItems:titleArray];
    self.segment.selectedSegmentIndex = 0;//默认显示中金所的数据
    self.segment.tintColor = DropColor;
    self.segment.frame = CGRectMake(0, 58, DEVICE_WIDTH, 50);
    [self.view addSubview:self.segment];
    [self.segment addTarget:self action:@selector(touchSegment:) forControlEvents:UIControlEventValueChanged];
}
//选中segment
-(void)touchSegment:(UISegmentedControl*)segment{
    [self.tableView removeFromSuperview];
    switch(segment.selectedSegmentIndex){
        case 0:
            NSLog(@"中金所");
            if(_zjsResult != nil){
                self.KlineList =  self.KlineList0;
                _searchResult = _zjsResult;
                [self addTableView];
            }
            else{
                self.sExchangeID = @"CFFEX";
                self.segmentIndex = 0;
                [self getData];
            }
            break;
        case 1:
            NSLog(@"郑商所");
            if(_zssResult != nil){
                self.KlineList =  self.KlineList1;
                _searchResult = _zssResult;
                [self addTableView];
            }
            else{
                self.segmentIndex = 1;
                self.sExchangeID = @"CZCE";
                [self getData];
            }
            break;
        case 2:
            NSLog(@"大商所");
            if(_dssResult != nil){
                self.KlineList =  self.KlineList2;
                _searchResult = _dssResult;
                [self addTableView];
            }
            else{
                self.segmentIndex = 2;
                self.sExchangeID = @"DCE";
                [self getData];
            }
            break;
        case 3:
            NSLog(@"上期所");
            if(_sqsResult != nil){
                self.KlineList =  self.KlineList3;
                _searchResult = _sqsResult;
                [self addTableView];
            }
            else{
                self.segmentIndex = 3;
                self.sExchangeID = @"SHFE";
                [self getData];
            }
            break;
        default:
            break;
    }
    [self addRefreshControl];//添加下拉刷新控件
    //[self GetData];
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
    if(self.refreshControl.refreshing){
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
        self.refreshFlag = 1;
        [self getData];
        [self.refreshControl endRefreshing];
        
    }
}
#pragma -mark tableview 代理协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResult count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *klinesCode = _searchResult[indexPath.row];
    //NSString *klinesCode = _searchResult[btn.tag];
    NSLog(@"历史行情 %@",klinesCode);
    //AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //self.TimeData =[self.iceQuote getTimeData:klinesCode];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        //[self.iceQuote Connect2Quote];
        //获取分时图数据
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [app.iceQuote Connect2Quote];
        self.TimeData =[app.iceQuote getTimeData:klinesCode];
        //self.TimeData =[self.iceQuote getTimeData:klinesCode];
        dispatch_sync(dispatch_get_main_queue(), ^{
            CandleLineVC* vc = [[CandleLineVC alloc]initWithScode:klinesCode KlineDataList:self.KlineListAll TimeData:self.TimeData];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        });
    });
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
    
    NSString* title = [_searchResult[indexPath.row] uppercaseString];//_searchResult[indexPath.row];

    cell.textLabel.text = title;
    UIImage* gotoImg = [UIImage imageNamed:@"goto.png"];
    UIImageView* gotoView = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-30, 10, 20, 20)];
    [gotoView setImage:gotoImg];
    [cell addSubview:gotoView];
    return cell;
}

#pragma -mark searchbar delegate
//search bar 过滤字符串 setter
- (void)setFilterString:(NSString *)filterString{
    _filterString = filterString;
    if(!filterString||filterString.length<=0){
        //self.searchResult = self.titlesArray;
    }
    else{
        
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self contains[c]%@",filterString];
        NSArray* allResult = [[NSArray alloc]init];
        //allResult = self.searchResult;//self.titlesArray;
        allResult = self.allTitlesArray;//所有数据 全局搜索
        self.searchResult = [allResult filteredArrayUsingPredicate:filterPredicate];
    }
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    if(!self.searchController.active){
        return;
    }
    self.filterString = self.searchController.searchBar.text;
}
//取消搜索 显示当前表格
- (void)willDismissSearchController:(UISearchController *)searchController{
    
    [self.searchView removeFromSuperview];
    switch (_segmentIndex) {
        case 0:
           self.searchResult = self.zjsResult;
            break;
        case 1:
            self.searchResult = self.zssResult;
            break;
        case 2:
            self.searchResult = self.dssResult;
            break;
        case 3:
            self.searchResult = self.sqsResult;
        default:
            break;
    }
    [self.tableView reloadData];
}
- (void)didDismissSearchController:(UISearchController *)searchController
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
