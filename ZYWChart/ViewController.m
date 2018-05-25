//
//  ViewController.m
//  ZYWChart
//
//  Created by 张有为 on 2016/12/17.
//  Copyright © 2016年 zyw113. All rights reserved.
//

#import "ViewController.h"
#import "CandleLineVC.h"
//ICE
#import <objc/Ice.h>
#import <objc/Glacier2.h>
#import <WpQuote.h>

@interface WpQuoteServerCallbackReceiverI : WpQuoteServerCallbackReceiver<WpQuoteServerCallbackReceiver>
@end

@implementation WpQuoteServerCallbackReceiverI
- (void)SendMsg:(ICEInt)itype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current
{
    NSLog(@"%@",strMessage);
}
@end

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,copy)   NSArray *titlesArray;
@property (nonatomic,copy)   NSMutableArray *titlesMArray;

@property (nonatomic) ICEInt iRet;
@property (nonatomic,copy) NSMutableArray* sCode;
//ICE
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<WpQuoteServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList;
@property (nonatomic) NSString* _Acc;
@property (nonatomic)NSString* _Pass;
@property (nonatomic)NSString* _IP;
@property (nonatomic)NSString* _Mac;
@property (nonatomic)NSString* strUserId;

@end

@implementation ViewController
//ICE
@synthesize communicator;
@synthesize twowayR;
@synthesize router;
@synthesize WpQuoteServerclientApiPrx;
@synthesize _Acc;
@synthesize _Pass;
@synthesize _IP;
@synthesize _Mac;
@synthesize strUserId;
@synthesize KlineList;

- (void) getKlineData{
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
            self.router = [GLACIER2RouterPrx checkedCast:[self.communicator getDefaultRouter]];//路由
            [self.router createSession:@"" password:@""];
            self.WpQuoteServerclientApiPrx = [WpQuoteServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];//返回具有所请求类型代理
            //启用主推回报
            ICEIdentity* callbackReceiverIdent= [ICEIdentity identity:@"callbackReceiver" category:[self.router getCategoryForClient]];
            id<ICEObjectAdapter> adapter = [self.communicator createObjectAdapterWithRouter:@"" router:self.router];
            [adapter activate];
            self.twowayR = [WpQuoteServerCallbackReceiverPrx uncheckedCast:[adapter add:[[WpQuoteServerCallbackReceiverI alloc]init] identity:callbackReceiverIdent]];
            [self getKline];
            [self loadData];
            //主线程 更新view
            dispatch_sync(dispatch_get_main_queue(), ^{
                self->_tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
                [self.view addSubview:self->_tableView];
                self->_tableView.delegate = self;
                self->_tableView.dataSource = self;
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
            NSString* s = [NSString stringWithFormat:@"Invalid router: %@", ex.reason];
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSLog(@"%@",s);
            });
        }
        @catch(ICEException* ex)
        {
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSLog(@"%@",ex);
            });
        }
    });
}
- (void)getKline
{
    //发送获取getkline
    _iRet = -1;
    NSString* strErr2 = @"";
    WpQuoteServerDayKLineList* DLL = [[WpQuoteServerDayKLineList alloc]init];
    NSMutableString* sExchangeID = [[NSMutableString alloc]initWithString:@"SHFE"];
    _iRet = [self.WpQuoteServerclientApiPrx GetDayKLine:sExchangeID DKLL:&DLL strErrInfo:&strErr2];
    //NSLog(@"iRet = %d",_iRet);
    self.KlineList = DLL;
}
- (void)loadData{
    
    //load data from Dll
    NSMutableArray* sCodeAll = [[NSMutableArray alloc]init];
    _sCode = [[NSMutableArray alloc]init];
    _titlesArray = [[NSArray alloc]init];
    NSEnumerator *enumerator = [self.KlineList objectEnumerator];
    id obj = nil;
    while (obj = [enumerator nextObject]){
        WpQuoteServerDayKLineCodeInfo* kline = [[WpQuoteServerDayKLineCodeInfo alloc]init];
        kline = obj;
        [sCodeAll addObject:kline.sCode];
        //NSLog(@"scoede= %@ high = %@ low = %@ open = %@ close = %@",kline.sCode,kline.sHighPrice,kline.sLowPrice,kline.sOpenPrice, kline.sLastPrice);
    }
    [_sCode addObject:sCodeAll[0]];
    
    for(int i=1;i<sCodeAll.count;i++){
        if(![sCodeAll[i] isEqual:sCodeAll[i-1]])
        {
            [_sCode addObject:sCodeAll[i]];
        }
    }
    _titlesArray = _sCode;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getKlineData];
    self.navigationItem.title = @"Home";
    UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(self.view.centerX-80, self.view.centerY-10, 160, 20)];
    lable.adjustsFontSizeToFitWidth = YES;
    lable.text = @"Loading data,Please wait";
    [self.view addSubview:lable];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_titlesArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSArray *controllers = @[@"LineVC",@"SlipLineVC",@"CandleLineVC",@"TimeLineVC"];
    NSString *klinesCode = _titlesArray[indexPath.row];
   
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
    NSString* title = _titlesArray[indexPath.row];
    cell.textLabel.text = title;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
