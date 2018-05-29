//
//  ViewController.m
//  ZYWChart
//
//  Created by 张有为 on 2016/12/17.
//  Copyright © 2016年 zyw113. All rights reserved.
//

#import "HomeVC.h"
#import "CandleLineVC.h"
//ICE
#import <objc/Ice.h>
#import <objc/Glacier2.h>
#import <WpQuote.h>
#import "HistoryVC.h"

@interface WpQuoteServerCallbackReceiverI : WpQuoteServerCallbackReceiver<WpQuoteServerCallbackReceiver>
@end

@implementation WpQuoteServerCallbackReceiverI
- (void)SendMsg:(ICEInt)itype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current
{
    NSLog(@"%@",strMessage);
}
@end

@interface HomeVC () <UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating, UISearchControllerDelegate>

@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIActivityIndicatorView *activeId;
@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,copy)   NSMutableArray *titlesArray;
@property (nonatomic,copy)   NSMutableArray *titlesMArray;
@property (nonatomic,strong) UIButton *getCandleLineBtn;
@property (nonatomic,strong) UIButton *getTimeLineBtn;
@property (nonatomic)        ICEInt iRet;
//@property (nonatomic,copy)   NSMutableArray* sCode;
@property (nonatomic,strong) UISearchBar *search;
@property (nonatomic,copy)   NSArray* searchResult;
@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic, copy) NSString *filterString;
//@property (nonatomic) BOOL connecting;


//ICE
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<WpQuoteServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList;
@property (nonatomic) NSString* _Acc;
@property (nonatomic) NSString* _Pass;
@property (nonatomic) NSString* _IP;
@property (nonatomic) NSString* _Mac;
@property (nonatomic) NSString* strUserId;

@end

@implementation HomeVC
//ICE
@synthesize KlineList;
@synthesize communicator;
@synthesize twowayR;
@synthesize router;
@synthesize WpQuoteServerclientApiPrx;
@synthesize _Acc;
@synthesize _Pass;
@synthesize _IP;
@synthesize _Mac;
@synthesize strUserId;




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Home";
    UINavigationBar.appearance.translucent = false;
    [self addLabel];
    [self addActiveId];
    [self connect2Server];
}

//conncet to server
- (void) connect2Server{

    [self.activeId startAnimating];
    ICEInitializationData* initData = [ICEInitializationData initializationData];
    initData.properties = [ICEUtil createProperties];
    [initData.properties load:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"config.client"]];
    
    initData.dispatcher = ^(id<ICEDispatcherCall> call, id<ICEConnection> con)
    {
        dispatch_sync(dispatch_get_main_queue(), ^ { [call run]; });
    };
    
    self.communicator = [ICEUtil createCommunicator:initData];//创建communicator
    //开线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        @try
        {
            //连接
            self.router = [GLACIER2RouterPrx checkedCast:[self.communicator getDefaultRouter]];//路由
            [self.router createSession:@"" password:@""];//创建session
            self.WpQuoteServerclientApiPrx = [WpQuoteServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];//返回具有所请求类型代理
            //启用主推回报
            ICEIdentity* callbackReceiverIdent= [ICEIdentity identity:@"callbackReceiver" category:[self.router getCategoryForClient]];
            id<ICEObjectAdapter> adapter = [self.communicator createObjectAdapterWithRouter:@"" router:self.router];
            [adapter activate];
            self.twowayR = [WpQuoteServerCallbackReceiverPrx uncheckedCast:[adapter add:[[WpQuoteServerCallbackReceiverI alloc]init] identity:callbackReceiverIdent]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                //self.getCandleLineBtn.enabled = YES;
                [self.activeId stopAnimating];
                [self.label removeFromSuperview];
                
                [self addgetCandleLineBtn];
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
            [communicator destroy];
            self.communicator = nil;
            return;
        }
    });
}

//getData
- (void)getData1{
    HistoryVC* vc = [[HistoryVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


//GetDayKLine
- (void)getKline
{
    _iRet = -1;
    NSString* strErr2 = @"";
    WpQuoteServerDayKLineList* DLL = [[WpQuoteServerDayKLineList alloc]init];
    NSMutableString* sExchangeID = [[NSMutableString alloc]initWithString:@"SHFE"];
    _iRet = [self.WpQuoteServerclientApiPrx GetDayKLine:sExchangeID DKLL:&DLL strErrInfo:&strErr2];
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

- (void)addActiveId{
    self.activeId = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeId.center = CGPointMake(self.view.centerX ,self.view.centerY+200);
    [self.view addSubview:self.activeId];
}
- (void)addLabel{
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.centerX-80, self.view.centerY-200, 160, 20)];
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.text = @"Loading data,Please wait";
    [self.view addSubview:self.label];
}
- (void)addgetCandleLineBtn{
    self.getCandleLineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.getCandleLineBtn.backgroundColor = [UIColor greenColor];
    self.getCandleLineBtn.layer.cornerRadius=20;
    self.getCandleLineBtn.frame = CGRectMake(self.view.centerX-50, self.view.centerY-25, 100, 50);
    [self.getCandleLineBtn setTitle:@"历史行情" forState:UIControlStateNormal];
    [self.getCandleLineBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.getCandleLineBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.getCandleLineBtn addTarget:self action:@selector(getData1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.getCandleLineBtn];
}
/*
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
 */

@end
