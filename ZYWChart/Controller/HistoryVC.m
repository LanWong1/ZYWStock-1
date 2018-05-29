//
//  HistoryVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/5/29.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "HistoryVC.h"
#import "CandleLineVC.h"
#import <objc/Ice.h>
#import <objc/Glacier2.h>
#import <WpQuote.h>

@interface HistoryVC ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating, UISearchControllerDelegate>
@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic, copy) NSString *filterString;
@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,copy)   NSMutableArray *titlesArray;
@property (nonatomic,copy)   NSMutableArray *titlesMArray;
@property (nonatomic,strong) UISearchBar *search;
@property (nonatomic,copy)   NSArray* searchResult;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList;
@property (nonatomic)        ICEInt iRet;


@property (nonatomic) id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
//@property (nonatomic) WpQuoteServerDayKLineList *KlineList;
@end

@implementation HistoryVC


@synthesize KlineList;
@synthesize WpQuoteServerclientApiPrx;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"合约代码";
    [self getKline];
    
    //[self addSearch];
    // Do any additional setup after loading the view.
}
//getData
- (void)getData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSLog(@"ssssdffffggg");
        [self getKline];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self addSearch];
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
    _iRet = [self.WpQuoteServerclientApiPrx GetDayKLine:sExchangeID DKLL:&DLL strErrInfo:&strErr2];
    NSLog(@"_iRet=%d",_iRet);
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
    self->_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,500)];
    [self.view addSubview:self->_tableView];
    self->_tableView.delegate = self;
    self->_tableView.dataSource = self;
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
    cell.textLabel.text = title;
    return cell;
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
-(void)didDismissSearchController:(UISearchController *)searchController
{
    
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
