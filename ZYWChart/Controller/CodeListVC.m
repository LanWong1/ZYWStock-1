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




@interface CodeListVC ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating, UISearchControllerDelegate>
@property (nonatomic,strong)  UISearchController *searchController;
@property (nonatomic, retain) UIRefreshControl * refreshControl;
@property (nonatomic, copy)   NSString *filterString;
@property (nonatomic,strong)  UITableView    *tableView;
@property (nonatomic,copy)    NSMutableArray *titlesArray;
@property (nonatomic,copy)    NSMutableArray *titlesMArray;
@property (nonatomic,strong)  UISearchBar *search;

@property (nonatomic,copy)    NSArray* zjsResult;
@property (nonatomic,copy)    NSArray* zssResult;
@property (nonatomic,copy)    NSArray* dssResult;
@property (nonatomic,copy)    NSArray* sqsResult;

@property (nonatomic,copy)    NSArray* searchResult;
@property (nonatomic,copy)    NSMutableArray* TimeData;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList;
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
    self.navigationItem.title = @"合约代码";
    [self addSearchButton];
    [self addSementView];
    self.sExchangeID = @"CFFEX";//默认为中金所
    self.segmentIndex = 0;
    [self GetData];
    
    // Do any additional setup after loading the view.
}
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

- (void)addSementView{
    NSArray *titleArray = [[NSArray alloc]initWithObjects:@"中金所",@"郑商所",@"大商所",@"上期所", nil];
    self.segment = [[UISegmentedControl alloc]initWithItems:titleArray];
    self.segment.selectedSegmentIndex = 0;
    self.segment.tintColor = RoseColor;
    self.segment.frame = CGRectMake(0, 58, DEVICE_WIDTH, 50);
    [self.view addSubview:self.segment];
    [self.segment addTarget:self action:@selector(touchSegment:) forControlEvents:UIControlEventValueChanged];
}
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
                [self GetData];
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
                [self GetData];
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
                [self GetData];
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
                [self GetData];
            }
            break;
        default:
            break;
    }
    [self addRefreshControl];
    //[self GetData];
}

//conncet to server
- (void) GetData{
    [self.activeId startAnimating];
    //开线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        @try
        {
            self.iceQuote = [[ICEQuote alloc]init];
            [self.iceQuote Connect2Quote];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.activeId stopAnimating];
                [self.label removeFromSuperview];
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

- (void)addActiveId{
    self.activeId = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeId.center = CGPointMake(self.view.centerX ,self.view.centerY+200);
    [self.view addSubview:self.activeId];
}
- (void)addLabel{
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.centerX-40, self.view.centerY-200, 80, 20)];
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.textAlignment  = NSTextAlignmentCenter;
    self.label.text = @"Please Wait";
    [self.view addSubview:self.label];
}

//getData
- (void)getData{
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
            [self addTableView];
            //[self addSearch];
            [self addRefreshControl];
            });
    });
}


//GetDayKLine
- (void)getKline
{
    [self.iceQuote Connect2Quote];
    self.KlineList = [self.iceQuote GetDayKline:self.sExchangeID];
    [self loadData];
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
    _searchResult = _titlesArray;
    
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
   
    //self.tableView.hidden = YES;
    //[self addTableView];
    //self.tableView.tableHeaderView = view;
}
//tableview
- (void)addTableView{
    
    self->_tableView = [[UITableView alloc] init];
    //self->_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT)];
    
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
#pragma 下拉刷新
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResult count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *klinesCode = _searchResult[indexPath.row];
    //NSString *klinesCode = _searchResult[btn.tag];
    NSLog(@"历史行情 %@",klinesCode);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [self.iceQuote Connect2Quote];
        self.TimeData =[self.iceQuote getTimeData:klinesCode];
        dispatch_sync(dispatch_get_main_queue(), ^{
            CandleLineVC* vc = [[CandleLineVC alloc]initWithScode:klinesCode KlineDataList:self.KlineList TimeData:self.TimeData];
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
//    UIButton* btn = [[UIButton alloc]init];
//    btn = [self setButton:@"历史行情" xPosition:100];
//    btn.tag = indexPath.row;
//    btn.backgroundColor = DropColor;
    //[btn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
    
//    UIButton *btn1 = [[UIButton alloc]init];
//    btn1 = [self setButton:@"分时图" xPosition:100];
//    btn1.backgroundColor = RoseColor;
//    btn1.tag = indexPath.row+[_searchResult count];
//    [btn1 addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
//    UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-100, 10, 80, 35)];
//    lable.text = @"点击查看";
    cell.textLabel.text = title;
    UIImage* gotoImg = [UIImage imageNamed:@"goto.png"];
    UIImageView* gotoView = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-30, 10, 20, 20)];
    [gotoView setImage:gotoImg];
    [cell addSubview:gotoView];
    return cell;
}
//button设置
- (UIButton*)setButton:(NSString*)title xPosition:(CGFloat) x {
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-x, 10, 80, 35)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    //btn.layer.cornerRadius=20;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    return btn;
}
////按下行情或者分时按钮
//- (void)btnPress:(id)sender{
//    UIButton*btn  = (UIButton*)sender;
//
//    //行情button按下
//    if(btn.tag<[_searchResult count])
//    {
//        NSString *klinesCode = _searchResult[btn.tag];
//        NSLog(@"历史行情 %@",_searchResult[btn.tag]);
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
//            [self.iceQuote Connect2Quote];
//            self.TimeData =[self.iceQuote getTimeData:klinesCode];
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                CandleLineVC* vc = [[CandleLineVC alloc]initWithScode:klinesCode KlineDataList:self.KlineList TimeData:self.TimeData];
//                vc.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:vc animated:YES];
//            });
//        });
//    }
//
//}

#pragma -mark searchbar delegate
//search bar 过滤字符串 setter
- (void)setFilterString:(NSString *)filterString{
    _filterString = filterString;
    if(!filterString||filterString.length<=0){
        self.searchResult = self.titlesArray;
    }
    else{
        
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self contains[c]%@",filterString];
        NSArray* allResult = [[NSArray alloc]init];
        allResult = self.titlesArray;
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

- (void)willDismissSearchController:(UISearchController *)searchController{
    
    [self.searchView removeFromSuperview];
    self.searchResult = self.titlesArray;
    //[self.tableView reloadData];
}
- (void)didDismissSearchController:(UISearchController *)searchController
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
