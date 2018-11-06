//
//  WYLoginVC.m
//  ZYWChart
//
//  Created by IanWong on 2018/7/17.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "WYLoginVC.h"
#import "AppDelegate.h"
#import "QuickOrder.h"
#import "BuyVC.h"
#import "ICEQuickOrder.h"
#import "ICEQuote.h"
#import "checkVC.h"
#import "CodeListVC.h"
#import "QuickOrderCodeListVCViewController.h"
#import "SQLServerAPI.h"
#import "GDataXMLNode.h"
#import "ContracInfoModel.h"



#define USERNAME @"063607"
#define PASSWORD @"123456"


@interface WYLoginVC ()<UITextFieldDelegate,NSXMLParserDelegate>
@property (nonatomic,strong)  UIButton *LoginButton;
@property (nonatomic,strong)  UITextField *UserNameTextField;
@property (nonatomic,strong)  UITextField *PassWordTextField;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) dispatch_source_t timer1;
@property (nonatomic,strong)  UILabel *label;
@property (nonatomic,strong)  UIActivityIndicatorView *activeId;
@property (nonatomic,strong)  ICETool* iceTool;
@property (nonatomic)         NSMutableString* strFundAcc;
@property (nonatomic)         NSString* strAcc;
@property (nonatomic)         NSMutableString* strUserId;
@property (nonatomic,strong)  BuyVC *buyVC;
@property (nonatomic)         WpTradeAPIServerCallbackReceiverI* wpTradeAPIServerCallbackReceiverI;
@property (nonatomic)         int connectFlag;
@property (nonatomic)         int quoteConnectFlag;
@property (nonatomic)         int tradeConnectFlag;
@property (nonatomic)         AppDelegate* app;
@property (copy,nonatomic)    NSString* Pass;
@property (nonatomic)         NSString* strCmd;
@property (nonatomic)         UITabBarController *tab;
@property (nonatomic,assign)  int iRet;
@property (nonatomic,assign)  NSString *countStatus;
@property (nonatomic,assign)  BOOL rowChangeFlag;
@property (nonatomic,strong)  NSMutableArray<__kindof ContracInfoModel*> *contractInfoArray;


@end

@implementation WYLoginVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"wyloginVC");
//    NSInteger timer_ = (NSInteger) [NSProcessInfo processInfo].systemUptime*100;
//    NSString* userId = [NSString stringWithFormat:@"%ld",(long)timer_];
//    self.strUserId = [[NSMutableString alloc]initWithString:userId];
    
    self.strUserId = [[NSMutableString alloc]initWithString: [self getCurrentTime]];
    self.LoginButton = [self addLoginButton];
    self.UserNameTextField = [self addTextField:@"UserName" PositionX:100 PositionY:70];
    self.PassWordTextField = [self addTextField:@"Password" PositionX:100 PositionY:10];
    _quoteConnectFlag = 0;
    _tradeConnectFlag = 0;
    self.UserNameTextField.text = USERNAME;
    self.PassWordTextField.text = PASSWORD;
    self.PassWordTextField.secureTextEntry = YES;
    self.connectFlag = 0;
    [self addLabel];
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.userName = USERNAME;
    app.passWord = PASSWORD;
    app.userID = self.strUserId;
    self.rowChangeFlag = true;
    SQLServerAPI *sql = [SQLServerAPI shareInstance];
    sql.paremetersSeq = [NSMutableArray array];
        //self.userID = [NSString stringWithString:[self getCurrentTime]];
    // Do any additional setup after loading the view.
}

- (NSString*)getCurrentTime{
    NSDate * date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HHmmss";
    NSString *string = [formatter stringFromDate:date];
    NSLog(@"uiser id ==== %@",string);
    return string;
}


- (void)addActiveId{
    self.activeId = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeId.center = CGPointMake(self.view.centerX ,self.view.centerY+200);
    [self.view addSubview:self.activeId];
}
- (void)addLabel{
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.centerX-80, self.view.centerY-200, 160, 20)];
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.text = @"Connect to server,Please wait";
}

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
            NSLog(@"all elements = %@",children);
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
//conncet to server
- (void) connect2Server{
    
    ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
    SQLServerAPI  *sql   = [SQLServerAPI shareInstance];
    ICEQuote      *quote = [ICEQuote shareInstance];
    
    
    [self.view addSubview:self.label];
    [self addActiveId];
    [self.activeId startAnimating];
    //开线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        @try
        {
            NSLog(@"connect to server");
            //sql 接口
            [sql Connect2ICE];//sql连接服务器
            [self checkFundAccount];
            // [self getCode];
            
            //易捷接口
            [quickOrder  Connect2ICE];
            [quickOrder initiateCallback:self.strFundAcc];
            
            NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
            NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
            int ret = [quickOrder.quickOrder Login:@"" strCmd:self.strCmd strOut:&strOut strErrInfo:&strErroInfo];
           // NSLog(@"quickorder login ret=  %d",ret);
            if(ret == -1){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:strErroInfo preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSLog(@"dddddddddd");
                    [self.activeId removeFromSuperview];
                    [self.label removeFromSuperview];
 
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
           // [self setHeartbeat];//心跳
            //资金查询
//            [quickOrder queryFund:quickOrder.strFunAcc];
//            NSString *cmd1 = [NSString stringWithFormat:@"%@%@%@",quickOrder.strFunAcc,@"=",@"" ];
//            [quickOrder queryOrder:cmd1];
//            //资金消息
//            NSString *cmd = [NSString stringWithFormat:@"%@%@%@",quickOrder.strFunAcc,@"=",@"49088" ];
//            [quickOrder queryCode:quickOrder.strFunAcc];
            //交易时间
            //[quickOrder.quickOrder QueryCode:@"GetTime" strCmd:@"" strOut:&strOut strErrInfo:&strErroInfo];
           // NSLog(@"queryCode: %@",strOut);
            
            
            //行情接口
       
            [quote Connect2Quote];
            [quote initiateCallback:self.strAcc];
            [quote Login:self.strCmd];
            quote.userID = self.strUserId;

            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self.activeId removeFromSuperview];
                [self.label removeFromSuperview];

                [self setHeartbeat];//心跳
                //判断是否重新连接 若是重新连接 无需跳转页面
                if(self.connectFlag == 0){
                    self.connectFlag = 1;
                    [self addTabBarController];
                }
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
        @catch(ICEException* s)
        {
            NSLog(@"哈哈哈 :%@",s);
            [self showAlart];
        }
    });
}

//账号检测
-(void)checkFundAccount{
    SQLServerAPI *sql = [SQLServerAPI shareInstance];
    [sql.paremetersSeq removeAllObjects];
    int ret = -0;
    NSString *erroInfo = @"";
    NSString *outPutString = @"";
    [sql DBAddSqlParameter:@"fund_account" direction:SqlServerInput value:self.strFundAcc];
    [sql DBAddSqlParameter:@"error_no" direction:SqlServerOutput value:@"-1"];
    [sql DBAddSqlParameter:@"error_info" direction:SqlServerOutput value:erroInfo];
   
   
    
    @try{
        ret =  [sql.SQL ExecProc:@"pd_check_fundaccount" SQLPQS:sql.paremetersSeq strErrInfo:&erroInfo XMLSqlData:&outPutString];
        NSLog(@"account = %@  info = %@  ret = %d",outPutString,erroInfo ,ret);
        if(ret == 0){
            [self setAlertWithMessage:@"账号不存在或未开通交易权限"];
        }
        if(ret == -1){
            [self setAlertWithMessage:@"异常"];
        }
        NSData *outData = [NSData dataWithBytes:[outPutString UTF8String] length:[outPutString length]];
        NSXMLParser *parser = [[NSXMLParser alloc]initWithData:outData];
        [parser setDelegate:self];
        [parser parse];
        
        
        if([self.countStatus isEqualToString:@"1"]){
            NSLog(@"账号正常");
        }
        if([self.countStatus isEqualToString:@"0"]){
            [self setAlertWithMessage:@"账号冻结"];
        }
    }
    @catch(NSException *s){

        [self setAlertWithMessage:@"异常"];
        
    }
}



-(void)showAlart{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"请检查网络"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action){
                                                [self connect2Server];
                                                NSLog(@"重新连接");
                                            }]];
    [_tab presentViewController:alert animated:YES completion:nil];
}



- (void)addTabBarController{
    BuyVC* buy = [[BuyVC alloc]init];
    checkVC* check = [[checkVC alloc]init];
    QuickOrderCodeListVCViewController *list = [[QuickOrderCodeListVCViewController alloc]init];
    //CodeListVC* list = [[CodeListVC alloc]init];
    self.tab = [[UITabBarController alloc]init];
    UINavigationController* listNav = [[UINavigationController alloc]initWithRootViewController:list];
    UINavigationController* buyNav = [[UINavigationController alloc]initWithRootViewController:buy];
    UINavigationController* checkNav = [[UINavigationController alloc]initWithRootViewController:check];
    buyNav.tabBarItem.title = @"交易";
    buyNav.tabBarItem.image = [UIImage imageNamed:@"tradeNotSelected"];
    buyNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"tradeSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    listNav.tabBarItem.title = @"行情";
    listNav.tabBarItem.image = [UIImage imageNamed:@"quoNotSelectet"];
    listNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"quoSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    checkNav.tabBarItem.title = @"账户";
    checkNav.tabBarItem.image = [UIImage imageNamed:@"checkNotSelected"];
    checkNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"checkSelected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _tab.viewControllers = @[listNav,buyNav,checkNav];
    [self presentViewController:_tab animated:NO completion:nil];
}


- (void)setHeartbeat{
    // 创建GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 3 * NSEC_PER_SEC, 0); //每3秒执行
    // 事件回调
    dispatch_source_set_event_handler(_timer, ^{
       
        int iRet1 = -2;
        int iRet2 = -2;
        @try{
            ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
            ICEQuote *quote = [ICEQuote shareInstance];
            iRet1 = [quote HeartBeat:self.strAcc];
            //iRet1 = [sql heartBeat];
            iRet2 = [quickOrder HeartBeat:self.strCmd];
        }
        @catch(ICEException* s){
            NSLog(@"heart beat exception ==== %@",s);
            if(iRet1 != 0){
                dispatch_source_cancel(self->_timer);
                [self connect2Server];
            }
        }
        
        if(iRet1 != 0 | iRet2 != 0){
            NSLog(@"heart beat fails ==========");
            dispatch_source_cancel(self->_timer);
            [self connect2Server];
        }
    });
    // 开启定时器
    dispatch_resume(_timer);
}



//添加 textfield

-(UITextField*)addTextField:(NSString* )placeholder PositionX:(CGFloat)x PositionY:(CGFloat)y{
    UITextField* TextField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.centerX-x, self.view.centerY-y, 200, 30)];
    [TextField setPlaceholder:placeholder];
    [TextField setTextColor:[UIColor redColor]];
    TextField.borderStyle = UITextBorderStyleRoundedRect;
    TextField.backgroundColor = [UIColor whiteColor];
    TextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    TextField.clearsOnBeginEditing = YES;
    TextField.textAlignment = NSTextAlignmentCenter;//居中对齐
    TextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    TextField.returnKeyType = UIReturnKeyDone;
    TextField.keyboardType = UIKeyboardTypeASCIICapable;
    TextField.delegate = self;
    [self.view addSubview:TextField];
    return TextField;
}




-(UIButton*)addLoginButton{
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.centerX-50, self.view.centerY+50, 100, 80)];
    [btn setTitle:@"Login" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    btn.backgroundColor = DropColor;
    btn.layer.cornerRadius = 20;
    //btn.enabled = NO;
    [btn addTarget:self action:@selector(ButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}
//login button pressed 登录
-(void)ButtonPressed{
    
    if(self.UserNameTextField.text.length ==0|self.PassWordTextField.text.length == 0)
    {
        [self setAlertWithMessage:@"用户名或密码不能为空"];
    }
    else
    {

        self.strFundAcc = [[NSMutableString alloc]initWithString:self.UserNameTextField.text];
        
        
        ICEQuote *quote = [ICEQuote shareInstance];
        quote.strFunAcc = self.UserNameTextField.text;
        quote.strPassword = self.PassWordTextField.text;
        quote.userID = self.strUserId;
 
        ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
        quickOrder.strFunAcc = self.UserNameTextField.text;
        quickOrder.strUserId = self.strUserId;
        quickOrder.strPassword = self.PassWordTextField.text;
        
        
        
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        app.strCmd = [[NSString alloc]initWithFormat:@"%@%@%@%@%@",self.UserNameTextField.text,@"=",self.strUserId,@"=",self.PassWordTextField.text];
        app.strAcc = [NSString stringWithFormat:@"%@%@%@",self.strFundAcc,@"=",self.strUserId];
        
        
        
        
        self.strAcc = [NSString stringWithFormat:@"%@%@%@",self.strFundAcc,@"=",self.strUserId];
        self.strCmd = [[NSString alloc]initWithFormat:@"%@%@%@%@%@",self.UserNameTextField.text,@"=",self.strUserId,@"=",self.PassWordTextField.text];
        
        
        self.Pass = self.PassWordTextField.text;
      
        [self connect2Server];
    }
}




- (void)setAlertWithMessage:(NSString*)msg{
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"警告"
                                                                 message:msg
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"重试"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //Dispose of any resources that can be recreated.
}
#pragma mark     keyboard delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if(textField.text.length>0)
    {
        self.LoginButton.enabled = YES;
    }
    else{
        self.LoginButton.enabled = NO;
    }
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma --mark parser 代理
// 1.开始解析
-(void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"开始解析数据");
}

//2.正在解析
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    
   
    if([elementName isEqualToString:@"account_status"]){
        self.countStatus = @"account_status";
    }
    
    if([elementName isEqualToString:@"row"]){
         self.rowChangeFlag = !self.rowChangeFlag ;
        //NSLog(@"self.rowChangeFla = %d",self.rowChangeFlag);
        
    }
    
}
//3.XML文件中每一个元素解析完成
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
   
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{

    static BOOL flag;
    if(flag != self.rowChangeFlag){
        flag = self.rowChangeFlag;
        
    }
    else{
        
    }
    if([self.countStatus isEqualToString:@"account_status"]){
        self.countStatus = string;
    }
}

//4.XML所有元素解析完毕
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"XML所有元素解析完毕");
}
@end
