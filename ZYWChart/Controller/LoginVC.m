//
//  LoginVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/6.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "LoginVC.h"
#import "BaseNavigationController.h"
//#import <objc/Ice.h>
//#import <objc/Glacier2.h>
#import "WpTrade.h"
#import "ICETool.h"
#import "BuyVC.h"



@interface LoginVC ()<UITextFieldDelegate>

@property (nonatomic,strong)  UIButton *LoginButton;
@property (nonatomic,strong)  UITextField *UserNameTextField;
@property (nonatomic,strong)  UITextField *PassWordTextField;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic,strong)  UILabel *label;
@property (nonatomic,strong)  UIActivityIndicatorView *activeId;
@property (nonatomic,strong) ICETool* iceTool;
@property (nonatomic) NSMutableString* strFundAcc;
@property (nonatomic) NSMutableString* strAcc;
@property (nonatomic) NSMutableString* strUserId;
@property (nonatomic) NSString* loginStrCmd;
@property (nonatomic,strong)  BuyVC *buyVC;
@property (nonatomic) WpTradeAPIServerCallbackReceiverI* wpTradeAPIServerCallbackReceiverI;

@end

@implementation LoginVC




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
   // self.LoginButton.enabled = NO;
    //开线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        @try
        {
            self.iceTool = [[ICETool alloc]init];
            self.wpTradeAPIServerCallbackReceiverI=[self.iceTool Connect2ICE];
            self.strAcc = [[NSMutableString alloc]initWithFormat:@"%@%@%@",self.strFundAcc,@"=",self.strUserId ];
            [self.iceTool initiateCallback:self.strAcc];
            [self.iceTool Login:self.loginStrCmd];
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self setHeartbeat];
                [self.activeId removeFromSuperview];
                [self.label removeFromSuperview];
                //self.buyVC = [[BuyVC alloc]initWithICE:self.iceTool StrCmd:self.loginStrCmd wpTradeAPIServerCallbackReceiverI:self.wpTradeAPIServerCallbackReceiverI];
                UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:self.buyVC];
                [self presentViewController:nav animated:NO completion:nil];
                
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
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:s.reason
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    });
}


-(UITextField*)addTextField:(NSString* )placeholder PositionX:(CGFloat)x PositionY:(CGFloat)y{
    
    UITextField* TextField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.centerX-x, self.view.centerY-y, 200, 30)];
    [TextField setPlaceholder:placeholder];
    [TextField setTextColor:[UIColor redColor]];
    TextField.borderStyle = UITextBorderStyleRoundedRect;
    TextField.backgroundColor = [UIColor whiteColor];
    TextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    TextField.clearsOnBeginEditing = YES;
    TextField.textAlignment = NSTextAlignmentCenter;
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
//login button pressed
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
        {
            _loginStrCmd = [[NSString alloc]initWithFormat:@"%@%@%@%@%@",self.UserNameTextField.text,@"=",self.strUserId,@"=",self.PassWordTextField.text];
            self.strFundAcc = [[NSMutableString alloc]initWithString:self.UserNameTextField.text];
            [self connect2Server];
 
        }
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


- (void)setHeartbeat{
    // 创建GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 20 * NSEC_PER_SEC, 0); //每秒执行
    // 事件回调
    NSString* strCmd = [[NSString alloc]initWithFormat:@"%@%@%@%@%@",self.UserNameTextField.text,@"=",self.strUserId,@"=",self.PassWordTextField.text];
    
    dispatch_source_set_event_handler(_timer, ^{
        int iRet = -2;
        @try{

            iRet = [self.iceTool HeartBeat:strCmd];
        }
        @catch(ICEException* s){
            NSLog(@"heart beat fail");
        }
        if(iRet == -2){
            //重新连接
            NSLog(@"hhhkkkkkkkkkkllll");
            dispatch_source_cancel(self->_timer);
            
            [self connect2Server];
        }
    });
    // 开启定时器
    dispatch_resume(_timer);
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
