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



#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_MAX_LENGTH MAX(kScreenWidth,kScreenHeight)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)


@interface QuickOrderCodeListVCViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating, UISearchControllerDelegate>

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


@end

@implementation QuickOrderCodeListVCViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor blackColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor blackColor]};//设置标题文字为白色
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}



-(void)viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];//导航栏背景色
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];//设置返回字体颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;//设置状态时间文字为
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _codeArray = [NSMutableArray array];
    self.navigationItem.title = @"合约代码";
     _contractInfoArray = [NSMutableArray array];
    [self addSearchButton];
    [self getCodeList];//获取数据
    //注册通知

}




//获取列表
- (void) getCodeList{

    if(self.refreshFlag!= 1)
    {
        [self addActiveId];
        [self addLabel];
        [self.activeId startAnimating];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [self getCode];
        [_contractInfoArray enumerateObjectsUsingBlock:^(__kindof ContracInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_codeArray addObject:obj.contract_name];
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            _searchResult =[NSArray arrayWithArray: _codeArray];
            [self.activeId stopAnimating];
            [self.label removeFromSuperview];
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
        NSLog(@"account = %@  info = %@  ret = %d",outPutString,erroInfo ,ret);
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
//tableview
- (void)addTableView{
    self->_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, DEVICE_WIDTH, DEVICE_HEIGHT - 120) style:UITableViewStylePlain];
    self->_tableView.delegate = self;
    self->_tableView.dataSource = self;
    [self.view addSubview:self->_tableView];

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
        NSLog(@"%@",self.codeArray);
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResult count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sCode = _contractInfoArray[indexPath.row].contract_code;
    Y_StockChartViewController* vc = [[Y_StockChartViewController alloc]initWithScode:sCode];
    vc.futu_price_step = _contractInfoArray[indexPath.row].futu_price_step;
    vc.hidesBottomBarWhenPushed = YES;
    
   
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue; //设置选中的颜色
    [cell setEditingAccessoryType:UITableViewCellAccessoryCheckmark];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //NSString* title = [_searchResult[indexPath.row] uppercaseString];
    NSString* title = _searchResult[indexPath.row];
    cell.textLabel.text = title;
    cell.detailTextLabel.text  = _contractInfoArray[indexPath.row].contract_code;
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
