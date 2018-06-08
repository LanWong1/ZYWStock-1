//
//  LoginVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/6.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "LoginVC.h"
#import "BaseNavigationController.h"
#import "HomeVC.h"

#import <objc/Ice.h>
#import <objc/Glacier2.h>
//#import <WpQuote.h>
//#import "NpTrade.h"
#import "WpTrade.h"


//@interface WpQuoteServerCallbackReceiverI : WpQuoteServerCallbackReceiver<WpQuoteServerCallbackReceiver>
//@end
//
//@implementation WpQuoteServerCallbackReceiverI
//- (void)SendMsg:(ICEInt)itype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current
//{
//    NSLog(@"%@",strMessage);
//}
//@end



//@interface NpTradeAPIServerCallbackReceiverI : NpTradeAPIServerCallbackReceiver<NpTradeAPIServerCallbackReceiver>
//@end
//
//@implementation NpTradeAPIServerCallbackReceiverI
//- (void)SendMsg:(NSMutableString *)sType sMsg:(NSMutableString *)sMsg current:(ICECurrent *)current {
//    NSLog(@"哈哈哈  %@",sMsg);
//}
//@end
@interface WpTradeAPIServerCallbackReceiverI : WpTradeAPIServerCallbackReceiver<WpTradeAPIServerCallbackReceiver>
@end
@implementation WpTradeAPIServerCallbackReceiverI
- (void)SendMsg:(NSMutableString *)stype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current {
    NSLog(@"哈哈哈  %@",strMessage);
}



@end

@interface LoginVC ()<UITextFieldDelegate>

@property (nonatomic,strong)  UIButton *LoginButton;
@property (nonatomic,strong)  UITextField *UserNameTextField;
@property (nonatomic,strong)  UITextField *PassWordTextField;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIActivityIndicatorView *activeId;
@property (nonatomic,strong) HomeVC* homeVC;

//ICE
@property (nonatomic) id<ICECommunicator> communicator;
//@property (nonatomic) id<WpQuoteServerCallbackReceiverPrx> twowayR;
//@property (nonatomic) id<NpTradeAPIServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<WpTradeAPIServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
//@property (nonatomic) id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
//@property (nonatomic) id<NpTradeAPIServerClientApiPrx> NpTrade;
@property (nonatomic) id<WpTradeAPIServerClientApiPrx> WpTrade;
@property (nonatomic) NSMutableString* strFundAcc;
@property (nonatomic) NSMutableString* strAcc;
@property (nonatomic) NSMutableString* _Pass;
@property (nonatomic) NSMutableString* _IP;
@property (nonatomic) NSMutableString* _Mac;
@property (nonatomic) NSMutableString* strUserId;
@property (nonatomic) NSString* loginStrCmd;

@end

@implementation LoginVC


//ICE
//@synthesize KlineList;
//@synthesize communicator;
//@synthesize twowayR;
//@synthesize router;
//@synthesize WpQuoteServerclientApiPrx;
//@synthesize _Acc;
//@synthesize _Pass;
//@synthesize _IP;
//@synthesize _Mac;
//@synthesize strUserId;




- (void)viewDidLoad {
    [super viewDidLoad];
    NSInteger timer_ = (NSInteger) [NSProcessInfo processInfo].systemUptime*100;
    NSString* userId = [NSString stringWithFormat:@"%ld",(long)timer_];
    
    self.strUserId = [[NSMutableString alloc]initWithString:userId];
    self.LoginButton = [self addLoginButton];
    self.UserNameTextField = [self addTextField:@"UserName" PositionX:100 PositionY:70];
    self.PassWordTextField = [self addTextField:@"Password" PositionX:100 PositionY:10];
    self.UserNameTextField.text = @"200172";
    self.PassWordTextField.text = @"BS401885";
    self.PassWordTextField.secureTextEntry = YES;
    //[self connect2Server];
    // Do any additional setup after loading the view.
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
    [self.view addSubview:self.label];
}
//conncet to server
- (void) connect2Server{
    [self addLabel];
    [self addActiveId];
    [self.activeId startAnimating];
    self.LoginButton.enabled = NO;
    //开线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        @try
        {
            [self Reconnect];//连接服务器
            [self initiateCallback];
            [self Login];
            //[self queryOrder];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self setHeartbeat];
                [self.activeId removeFromSuperview];
                [self.label removeFromSuperview];
                if(self.homeVC == nil){
                   [self addHomeVC];
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
        @catch(ICEException* s)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:s.reason
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            
            [self presentViewController:alert animated:YES completion:nil];
            [self.communicator destroy];
            self.communicator = nil;
            return;
        }
    });
}

- (void)Reconnect{
    ICEInitializationData* initData = [ICEInitializationData initializationData];
    initData.properties = [ICEUtil createProperties];
    [initData.properties load:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"config.client"]];
    initData.dispatcher = ^(id<ICEDispatcherCall> call, id<ICEConnection> con)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{ [call run]; });
    };
    self.communicator = [ICEUtil createCommunicator:initData];//创建communicator
    //连接
    self.router = [GLACIER2RouterPrx checkedCast:[self.communicator getDefaultRouter]];//路由
    [self.router createSession:@"" password:@""];//创建session
    //self.NpTrade = [NpTradeAPIServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];
     self.WpTrade = [WpTradeAPIServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];
    //启用主推回报
    ICEIdentity* callbackReceiverIdent= [ICEIdentity identity:@"callbackReceiver" category:[self.router getCategoryForClient]];
    id<ICEObjectAdapter> adapter = [self.communicator createObjectAdapterWithRouter:@"" router:self.router];
    [adapter activate];
    self.twowayR = [WpTradeAPIServerCallbackReceiverPrx uncheckedCast:[adapter add:[[WpTradeAPIServerCallbackReceiverI alloc]init] identity:callbackReceiverIdent]];
}


-(UITextField*)addTextField:(NSString* )placeholder PositionX:(CGFloat)x PositionY:(CGFloat)y{
    
    UITextField* TextField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.centerX-x, self.view.centerY-y, 200, 30)];
    [TextField setPlaceholder:placeholder];
    [TextField setTextColor:[UIColor redColor]];
    TextField.borderStyle = UITextBorderStyleRoundedRect;
    TextField.backgroundColor = [UIColor whiteColor];
    TextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    TextField.clearsOnBeginEditing = YES;
    TextField.textAlignment = UITextAlignmentCenter;
    TextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    TextField.returnKeyType = UIReturnKeyDone;
    TextField.keyboardType = UIKeyboardTypeASCIICapable;
    TextField.delegate = self;
    [self.view addSubview:TextField];
    return TextField;
}
-(UIButton*)addLoginButton{
    
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.centerX-50, self.view.centerY+50, 100, 30)];
    [btn setTitle:@"Login" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    btn.backgroundColor = RoseColor;
    btn.layer.cornerRadius = 20;
    //btn.enabled = NO;
    [btn addTarget:self action:@selector(ButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

-(void)ButtonPressed{
  
    if(self.UserNameTextField.text.length ==0|self.PassWordTextField.text.length == 0)
    {
        [self setAlertWithMessage:@"用户名或密码不能为空"];
    }
    else
    {
        if([self.UserNameTextField.text isEqualToString:@"200172"]==NO | [self.PassWordTextField.text isEqualToString:@"BS401885"]==NO)
        {
            [self setAlertWithMessage:@"用户名或者密码错误"];
        }
        else
        {   _loginStrCmd = [[NSString alloc]initWithFormat:@"%@%@%@%@%@",self.UserNameTextField.text,@"=",self.strUserId,@"=",self.PassWordTextField.text];
            NSLog(@"login strcmd %@",_loginStrCmd);
            self.strFundAcc = [[NSMutableString alloc]initWithString:self.UserNameTextField.text];
            [self connect2Server];
        }
    }
}
- (void)addHomeVC{
    self.homeVC = [[HomeVC alloc]init];
    [self.homeVC activate:self.communicator router:self.router WpTradeAPIServerClientApiPrx:self.WpTrade loginCmd:self.loginStrCmd];
   // self.homeVC activate:self.communicator router:self.router NpTradeAPIServerClientApiPrx:<#(id<WpTradeAPIServerClientApiPrx>)#> loginCmd:<#(NSString *)#>
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:self.homeVC];
    [self presentViewController:nav animated:NO completion:nil];
}
//- (void)addHomeVC{
//    self.homeVC = [[HomeVC alloc]init];
//    [self.homeVC activate:self.communicator router:self.router NpTradeAPIServerClientApiPrx:self.NpTrade loginCmd:self.loginStrCmd];
//    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:self.homeVC];
//    [self presentViewController:nav animated:NO completion:nil];
//}
- (WpTradeAPIServerMutableSTRLIST*)queryOrder{
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
   // NpTradeAPIServerMutableSTRLIST* outList = [[NpTradeAPIServerMutableSTRLIST alloc]initWithCapacity:0];
     WpTradeAPIServerMutableSTRLIST* outList= [[WpTradeAPIServerMutableSTRLIST alloc]initWithCapacity:0];
    //[self.NpTrade QueryFund:@"" strCmd:self.loginStrCmd ListEntrust:&outList strOut:&strOut strErrInfo:&strErroInfo];
    [self.WpTrade QueryFund:@"" strCmd:self.loginStrCmd ListFund:&outList strOut:&strOut strErrInfo:&strErroInfo];
       // [self.NpTrade QueryFund:@"" strCmd:self.loginStrCmd ListFund:&outList strOut:&strOut strErrInfo:&strErroInfo];
    return outList;
}
- (void)initiateCallback{
    self.strAcc = [[NSMutableString alloc]initWithFormat:@"%@%@%@",self.strFundAcc,@"=",self.strUserId ];
    NSLog(@"_strACC %@",_strAcc);
    [self.WpTrade initiateCallback:self.strAcc proxy:self.twowayR];
     //[self.NpTrade initiateCallback:self.strAcc proxy:self.twowayR];
}
- (void)Login{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    NSLog(@"longin %@",_loginStrCmd);
    //[self.NpTrade Login:@"" strCmd:_loginStrCmd strOut:&strOut strErrInfo:&strErroInfo];
    [self.WpTrade Login:@"" strCmd:_loginStrCmd strOut:&strOut strErrInfo:&strErroInfo];
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
- (void)setHeartbeat{
    // 创建GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 20 * NSEC_PER_SEC, 0); //每秒执行
    // 事件回调

    NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@%@%@",self.UserNameTextField.text,@"=",self.strUserId,@"=",self.PassWordTextField.text];
    
    dispatch_source_set_event_handler(timer, ^{
        int iRet = -2;
        NSLog(@"hearbeat");
        NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
        NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
        @try{
            NSLog(@"heart beat strcmd%@",strCmd);
            //iRet = [self.NpTrade HeartBeat:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
            iRet = [self.WpTrade HeartBeat:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
            NSLog(@"iRet=%d",iRet);
        }
        @catch(ICEException* s){
            NSLog(@"heart beat fail");
        }
        if(iRet == -2){
            //重新连接
            dispatch_source_cancel(timer);
            [self connect2Server];
        }
    });
    // 开启定时器
    dispatch_resume(timer);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if(textField.text.length>0)
    {
        self.LoginButton.enabled = YES;
    }
    else{
        self.LoginButton.enabled = NO;
    }
    
    
    //NSLog(@"%@",textField.text);
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

@end
