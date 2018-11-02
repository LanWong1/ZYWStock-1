//
//  QuickOrderCodeListVCViewController.m
//  ZYWChart
//
//  Created by zdqh on 2018/9/5.
//  Copyright © 2018年 zyw113. All rights reserved.
//

#import "QuickOrderCodeListVCViewController.h"
#import "ICEQuickOrder.h"
#import "Y_StockChartViewController.h"
#import "ContracInfoModel.h"
#import "GDataXMLNode.h"
#import "SQLServerAPI.h"
#import "ICEQuote.h"
#import "QuoteModel.h"
#import "QuoteArrayModel.h"
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_MAX_LENGTH MAX(kScreenWidth,kScreenHeight)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)


@interface QuickOrderCodeListVCViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating, UISearchControllerDelegate,QuoteArrayModelDelegate>

@property (nonatomic,strong)  UIButton *searchBtn;
@property (nonatomic,strong)  UISearchController *searchController;
@property (nonatomic,strong)  UISearchBar *search;
@property (nonatomic,strong)  UIView      *searchView;
@property (nonatomic, copy)   NSString    *filterString;
@property (nonatomic,strong)  UITableView *tableView;
@property (nonatomic,strong)  UILabel *label;
@property (nonatomic,strong)  UIActivityIndicatorView *activeId;
@property (nonatomic,copy)    NSArray* searchResult;
@property (nonatomic,copy)    NSMutableArray* codeArray;
@property (nonatomic)         ICEInt refreshFlag;
@property (nonatomic,strong)  UIRefreshControl   *refreshControl;
@property (nonatomic,strong)  NSMutableArray<__kindof ContracInfoModel*> *contractInfoArray;
@property (nonatomic,strong)  NSMutableArray *subscribedIndex;
@property (nonatomic,strong)  NSMutableArray<__kindof QuoteModel*> *quoteModelArray;
@property (nonatomic,strong)  WpQuoteServerCallbackReceiverI* reciver;
@property (nonatomic,strong)  QuoteModel *quoteModel;
@property (nonatomic,strong)  QuoteArrayModel *quoteArrayModel;
@end

@implementation QuickOrderCodeListVCViewController



- (void)viewWillAppear:(BOOL)animated{
   
    [super viewWillAppear: animated];
    self.navigationController.navigationBar.barTintColor = DropColor;//导航栏背景色
    
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;//设置状态时间文字为白色
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    _subscribedIndex = [NSMutableArray array];
    _codeArray = [NSMutableArray array];
    _quoteArrayModel = [QuoteArrayModel shareInstance];
    _quoteArrayModel.delegate = self;
    [QuoteArrayModel shareInstance].quoteModelArray = [NSMutableArray array];
    
    _quoteModelArray = [NSMutableArray array];
    
 
    self.navigationItem.title = @"合约代码";
     _contractInfoArray = [NSMutableArray array];
    self.reciver = [[WpQuoteServerCallbackReceiverI alloc]init];
    //self.reciver.delegate = self;
    
    
    [self addSearchButton];
    [self getCodeList];//获取数据
  
    //注册通知
//[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(quoteDataChange:) name:@"quoteNotity" object:nil];
[[NSNotificationCenter defaultCenter]addObserver:[QuoteArrayModel shareInstance] selector:@selector(quoteDataChange:) name:@"quoteNotity" object:nil];
}

- (void)reloadData:(NSMutableArray *)array{
    NSLog(@"reload data=============");
    [_quoteModelArray addObjectsFromArray:array];
    [_tableView reloadData];
}



#pragma mark    获取数据

//获取列表
- (void) getCodeList{

    if(self.refreshFlag!= 1)
    {
        [self addActiveId];
        [self addLabel];
        [self.activeId startAnimating];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [self getCode];//获取合约信息
        [_contractInfoArray enumerateObjectsUsingBlock:^(__kindof ContracInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_codeArray addObject:obj.contract_name];
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            _searchResult =[NSArray arrayWithArray: _codeArray];
            [self.activeId stopAnimating];
            [self.label removeFromSuperview];
            [self addHeaderView];
            [self addTableView];
            [self addRefreshControl];
        });
    });
}

//获取合约信息
-(void)getCode{

    SQLServerAPI *sql = [SQLServerAPI shareInstance];
    [sql.paremetersSeq removeAllObjects];
    int ret = 0;
    NSString *erroInfo = @"";
    NSString *outPutString = @"";
    NSLog(@"%@",sql.paremetersSeq);
    @try{
        ret =  [sql.SQL ExecProc:@"pd_get_contractcode" SQLPQS:sql.paremetersSeq strErrInfo:&erroInfo XMLSqlData:&outPutString];
        //NSLog(@"account = %@  info = %@  ret = %d",outPutString,erroInfo ,ret);
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithXMLString:outPutString error:nil];
        GDataXMLElement *rootElement = [doc rootElement];
        NSArray *division=[rootElement children];
        for(int i =0; i<division.count;i++){
            GDataXMLElement *ele = [division objectAtIndex:i];
            NSArray *children = [ele children];
            ContracInfoModel *model = [[ContracInfoModel alloc]init];
            for(int j =0;j<children.count;j++){
                GDataXMLElement *element = [children objectAtIndex:j];
                NSString *value = [element stringValue];
                if([[element name] isEqualToString:@"exchange_type"]){
                    model.exchange_type = value;
                }
                if([[element name] isEqualToString:@"contract_name"]){
                    model.contract_name = value;
                }
                if([[element name] isEqualToString:@"contract_type"]){
                    model.contract_type = value;
                }
                if([[element name] isEqualToString:@"open_limited"]){
                    model.open_limited = value;
                }
                if([[element name] isEqualToString:@"contract_code"]){
                    model.contract_code = value;
                }
                if([[element name] isEqualToString:@"close_limited"]){
                    model.close_limited = value;
                }
                if([[element name] isEqualToString:@"futu_price_step"]){
                    model.futu_price_step = value;
                }
                if([[element name] isEqualToString:@"futu_price_multiplier"]){
                    model.futu_price_multiplier = value;
                }
                if([[element name] isEqualToString:@"futu_bail_rate"]){
                    model.futu_bail_rate = value;
                }
                if([[element name] isEqualToString:@"sortid"]){
                    model.sortid = value;
                }
                if([[element name] isEqualToString:@"memo"]){
                    model.memo = value;
                }
                if([[element name] isEqualToString:@"enabled"]){
                    model.enabled = value;
                }
            }
            [_contractInfoArray addObject:model];
        }
        if(ret == 1){
            NSLog(@"正常");
        }
        if(ret == -1){
            [self setAlertWithMessage:@"异常"];
        }
    }
    @catch(NSException *s){
        [self setAlertWithMessage:@"异常"];
    }
}
//设置警告窗口
- (void)setAlertWithMessage:(NSString*)msg{
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"警告"
                                                                 message:msg
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"重试"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
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
        [self getCodeList];
        [self.refreshControl endRefreshing];
        
    }
}

#pragma mark 添加View
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



//添加searchbar
- (void)addSearch{
    [UIView animateWithDuration:0.25f animations:^{
        if(IS_IPHONE_X){
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+55+30, DEVICE_WIDTH, self.tableView.frame.size.height)];
        }
        else{
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+55, DEVICE_WIDTH, self.tableView.frame.size.height)];
        }
    }];
    
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
    if(IS_IPHONE_X){
        self.searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 55+30, DEVICE_WIDTH, self.searchController.searchBar.frame.size.height)];
    }
    else{
        self.searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 55, DEVICE_WIDTH, self.searchController.searchBar.frame.size.height)];
    }
    [self.searchView addSubview:self.search];
    [self.view addSubview:self.searchView];

}
//转圈圈
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
- (void)addHeaderView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,60, DEVICE_WIDTH, 40)];
    view.backgroundColor = [UIColor lightGrayColor];
    view.alpha = 0.8;
    
    UILabel *lable3 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, view.height)];
    lable3.adjustsFontSizeToFitWidth = YES;
    lable3.text = @"名称";
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(130, 0, 50, view.height)];
    lable.adjustsFontSizeToFitWidth = YES;
    lable.text = @"最新价";
    
    UILabel *lable1 = [[UILabel alloc]initWithFrame:CGRectMake(240, 0, 50, view.height)];
    lable1.adjustsFontSizeToFitWidth = YES;
    lable1.text = @"涨跌";
    
    UILabel *lable2 = [[UILabel alloc]initWithFrame:CGRectMake(350, 0, 50, view.height)];
    lable2.adjustsFontSizeToFitWidth = YES;
    lable2.text = @"持仓量";

    [view addSubview:lable];
    [view addSubview:lable1];
    [view addSubview:lable2];
    [view addSubview:lable3];
    
    [self.view addSubview:view];
    
}
//tableview
- (void)addTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, DEVICE_WIDTH, DEVICE_HEIGHT - 120) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView.hidden = YES;
    [self.view addSubview:_tableView];

}
- (void)subscibe:(NSString*)sCode{
    ICEQuote* iceQuote = [ICEQuote shareInstance];
    NSString* cmdType = @"CTP,";
    NSString *strAcc = [NSString stringWithFormat:@"%@%@%@",iceQuote.strFunAcc,@"=",iceQuote.userID];
    cmdType =  [cmdType stringByAppendingString:strAcc];
    [iceQuote SubscribeQuote:cmdType strCmd:sCode];
}
#pragma mark searchbar delegate
//search bar 过滤字符串 setter
- (void)setFilterString:(NSString *)filterString{
    _filterString = filterString;
    if(!filterString||filterString.length<=0){
        //self.searchResult = self.titlesArray;
    }
    else{
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self contains[c]%@",filterString];
        NSArray* allResult = [[NSArray alloc]init];
        allResult = self.codeArray;//所有数据 全局搜索
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
    
    [UIView animateWithDuration:0.25f animations:^{
        NSLog(@"move");
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y-55, DEVICE_WIDTH, self.tableView.frame.size.height)];
    }];
    [self.searchView removeFromSuperview];
    _searchResult = _codeArray;
    
    [self.tableView reloadData];
}

#pragma mark  tableview delegate
//tableview 的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResult count];
}
// 选中 cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sCode = _contractInfoArray[indexPath.row].contract_code;
    NSString *name = _contractInfoArray[indexPath.row].contract_name;
    NSString *title = [NSString stringWithFormat:@"%@(%@)",name,sCode];
    Y_StockChartViewController* vc = [[Y_StockChartViewController alloc]initWithScode:sCode];
    vc.title = title;
    vc.futu_price_step = _contractInfoArray[indexPath.row].futu_price_step;

    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
//每个 cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block NSString *lastPrice;
    __block NSString *priceChangePercentage;
    __block NSString *openInterest;
 
    static NSString *identifier = @"identifier";
    if(![_subscribedIndex containsObject:@(indexPath.row)] ){
        [_subscribedIndex addObject:@(indexPath.row)];
        [self subscibe:_contractInfoArray[indexPath.row].contract_code];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    [_quoteModelArray enumerateObjectsUsingBlock:^(__kindof QuoteModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:0 error:NULL];
        NSString *code = [regular stringByReplacingMatchesInString:obj.instrumenID options:0 range:NSMakeRange(0, [obj.instrumenID length]) withTemplate:@""];
        if([_contractInfoArray[indexPath.row].contract_code containsString:code]){
            lastPrice    = obj.lastPrice;     //最新价
            priceChangePercentage  = obj.priceChangePercentage;   //涨幅百分比
            openInterest = obj.openInterest;  //持仓量
            *stop = YES;
        }
    }];

    

    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(130, 0, 60, cell.height)];
    //lable.adjustsFontSizeToFitWidth = YES;
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize:16];
    lable.text = lastPrice;
    [lable setTextColor:RoseColor];
    
    UILabel *lable1 = [[UILabel alloc]initWithFrame:CGRectMake(230, 0, 60, cell.height)];
    //lable1.adjustsFontSizeToFitWidth = YES;
    lable1.text = priceChangePercentage;
    lable1.font = [UIFont systemFontOfSize:16];
    lable1.textAlignment = NSTextAlignmentCenter;
    
    [lable1 setTextColor:RoseColor];
    if([lable1.text containsString:@"-"]){
        [lable1 setTextColor:DropColor];
        [lable setTextColor:DropColor];
    }
    
    UILabel *lable2 = [[UILabel alloc]initWithFrame:CGRectMake(330, 0, 80, cell.height)];
    lable2.font = [UIFont systemFontOfSize:16];
    lable2.textAlignment = NSTextAlignmentCenter;
    lable2.text = openInterest;

    cell.selectionStyle = UITableViewCellSelectionStyleBlue; //设置选中的颜色
    NSString* title = _searchResult[indexPath.row];
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.text  = _contractInfoArray[indexPath.row].contract_code;
    [cell addSubview:lable];
    [cell addSubview:lable1];
    [cell addSubview:lable2];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
