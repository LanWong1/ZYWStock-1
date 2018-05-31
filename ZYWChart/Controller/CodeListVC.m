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
//#import "EvenRefresh.h"


@interface CodeListVC ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating, UISearchControllerDelegate>
@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic, retain) UIRefreshControl * refreshControl;
@property (nonatomic, copy) NSString *filterString;
@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,copy)   NSMutableArray *titlesArray;
@property (nonatomic,copy)   NSMutableArray *titlesMArray;
@property (nonatomic,strong) UISearchBar *search;
@property (nonatomic,copy)   NSArray* searchResult;
@property (nonatomic,copy)   NSMutableArray* array;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList;
@property (nonatomic)        ICEInt iRet;
@property (nonatomic) id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id session;
@property (nonatomic)        ICEInt refreshFlag;

@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIActivityIndicatorView *activeId;
@property (nonatomic,strong) UIButton *btn;

@property (nonatomic,strong) TimeLineVC *timeLineVC;

@end


@implementation CodeListVC

@synthesize communicator;
@synthesize session;
@synthesize router;
@synthesize KlineList;
@synthesize WpQuoteServerclientApiPrx;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"看行情";
    if(self.KlineList == nil)
    {
        [self getData];
    }
    else{
        [self addSearch];
    }
    
    
    //[self addSearch];
    // Do any additional setup after loading the view.
}
- (void)addActiveId{
    self.activeId = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeId.center = CGPointMake(self.view.centerX ,self.view.centerY+200);
    [self.view addSubview:self.activeId];
}

- (void)addLabel{
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.centerX-80, self.view.centerY-50, 160, 20)];
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.text = @"Loading data,Please wait...";
    [self.view addSubview:self.label];
}


-(void)activate:(id<ICECommunicator>)c
         router:(id<GLACIER2RouterPrx>)r
        WpQuoteServerclientApiPrx:(id<WpQuoteServerClientApiPrx>)l
{
    self.communicator = c;
    self.router = r;
    self.WpQuoteServerclientApiPrx = l;
}
//getData
- (void)getData{
    if(self.refreshFlag!= 1)
    {
        [self addActiveId];
        [self addLabel];
        [self.activeId startAnimating];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        
        [self getKline];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.activeId stopAnimating];
            [self.activeId removeFromSuperview];
            [self.label removeFromSuperview];
            [self addSearch];
            [self addRefreshControl];
            });
    });
}


//GetDayKLine
- (void)getKline
{
    _iRet = -1;
    NSString* strErr2 = @"";
    WpQuoteServerDayKLineList* DLL = [[WpQuoteServerDayKLineList alloc]init];
    NSMutableString* sExchangeID = [[NSMutableString alloc]initWithString:@"SHFE"];
    @try{
        _iRet = [self.WpQuoteServerclientApiPrx GetDayKLine:sExchangeID DKLL:&DLL strErrInfo:&strErr2];
    }
    @catch(ICEException* s)
    {
        NSLog(@"%@",s);
    }
    self.KlineList = DLL;
    [self loadData];
}

//get titlesArray
- (void)loadData{
    NSMutableArray* sCodeAll = [[NSMutableArray alloc]init];
    _titlesArray = [[NSMutableArray alloc]init];
    _searchResult = [[NSMutableArray alloc]init];
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
    _searchResult = _titlesArray;
}
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
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 55, DEVICE_WIDTH, self.searchController.searchBar.frame.size.height)];
    [view addSubview:self.search];
    [self addTableView];
    self.tableView.tableHeaderView = view;
}

- (void)addTableView{
    self->_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT)];
    [self.view addSubview:self->_tableView];
    self->_tableView.delegate = self;
    self->_tableView.dataSource = self;
}
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
    CandleLineVC* vc = [[CandleLineVC alloc]initWithScode:klinesCode KlineDataList:self.KlineList];
    [self.navigationController pushViewController:vc animated:YES];
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
    NSString* title = _searchResult[indexPath.row];

    UIButton* btn = [[UIButton alloc]init];
    btn = [self setButton:@"历史行情" xPosition:200];
    btn.tag = indexPath.row;
    btn.backgroundColor = [UIColor greenColor];
    [btn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn1 = [[UIButton alloc]init];
    btn1 = [self setButton:@"分时图" xPosition:100];
    btn1.backgroundColor = RoseColor;
    btn1.tag = indexPath.row+[_searchResult count];
    [btn1 addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];

    cell.textLabel.text = title;
    [cell addSubview:btn];
    [cell addSubview:btn1];
    return cell;
}
- (UIButton*)setButton:(NSString*)title xPosition:(CGFloat) x {
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-x, 10, 80, 35)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    btn.layer.cornerRadius=20;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    return btn;
}
- (void)btnPress:(id)sender{
    
    UIButton*btn  = (UIButton*)sender;
    if(btn.tag<[_searchResult count])
    {
        NSLog(@"历史行情 %ld",btn.tag);
        NSString *klinesCode = _searchResult[btn.tag];
        CandleLineVC* vc = [[CandleLineVC alloc]initWithScode:klinesCode KlineDataList:self.KlineList];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        NSInteger tag = btn.tag;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [self getTimeData:self.searchResult[tag-[self.searchResult count]]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.timeLineVC = [[TimeLineVC alloc]init];
                self.timeLineVC.timeData = self.array;
                self.timeLineVC.sCode = self.searchResult[tag-[self.searchResult count]];
                [self.navigationController pushViewController:self.timeLineVC animated:YES];  
            });
        });
    }
  
}
- (void)getTimeData:(NSString*)sCode {
    
    NSMutableString* strOut = [[NSMutableString alloc]init];
    NSString* Time = [self getCurrentTime];
    NSString* Code = sCode;
    NSLog(@"%@",Code);
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@" ,Code,@"=",Time];
    [self.WpQuoteServerclientApiPrx GetKLine:@"minute" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
    NSLog(@"%@",strOut);
    if([strOut length]> 0){
        self.array = [[strOut componentsSeparatedByString:@"|"] mutableCopy];
        NSLog(@"%@",self.array);
        [self.array removeLastObject];
    }

}

- (NSString*)getCurrentTime{
    NSDate * date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HHmmss";
    NSString *string = [formatter stringFromDate:date];
    return string;
}


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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    if(!self.searchController.active){
        return;
    }
    self.filterString = self.searchController.searchBar.text;
}

- (void)willDismissSearchController:(UISearchController *)searchController{
    
    self.searchResult = self.titlesArray;
    [self.tableView reloadData];
}
- (void)didDismissSearchController:(UISearchController *)searchController
{
    
}
@end
