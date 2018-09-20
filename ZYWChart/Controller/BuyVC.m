//
//  BuyVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/5.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "BuyVC.h"
#import "ICETool.h"
//#import "BaseNavigationController.h"
//#import "HomeVC.h"
#import "AppDelegate.h"
#import "ICENpTrade.h"

@interface BuyVC ()<UITextFieldDelegate>

@property (nonatomic,strong)  UIButton *buyButton;
@property (nonatomic,strong)  UITextField *ScodeTextField;
@property (nonatomic,strong)  UITextField *CountTextField;
@property (nonatomic,strong)  UITextField *PriceTextField;
@property (nonatomic,strong)  UIButton *OpenButton;
@property (nonatomic,strong)  UIButton *CloseButton;
@property (nonatomic) NSString* loginStrCmd;
@property (nonatomic) ICETool* iceTool;
@property (nonatomic) NpTradeAPIServerCallbackReceiverI* npTradeAPIServerCallbackReceiverI;
@property (nonatomic) WpTradeAPIServerCallbackReceiverI* wpTradeAPIServerCallbackReceiverI;
@property (nonatomic) NSMutableArray* Msg;
@property (nonatomic,strong)  UIActivityIndicatorView *activeId;


@end

@implementation BuyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"交易";
    self.ScodeTextField = [self addTextField:@"合约代码" PositionX:100 PositionY:150 Lenth:200];
    self.ScodeTextField.text = self.Scode;
    self.CountTextField = [self addTextField:@"手数" PositionX:100 PositionY:100 Lenth:100];
    self.PriceTextField = [self addTextField:@"价格" PositionX:0   PositionY:100 Lenth:100];
    
    self.OpenButton = [self addButton:@"买入" PositionX:110 PositionY:-10];
    self.OpenButton.tag = 500;
    self.OpenButton.backgroundColor = RoseColor;
    self.CloseButton = [self addButton:@"卖出" PositionX:-30 PositionY:-10];
    self.CloseButton.tag = 500+1;
    self.CloseButton.backgroundColor = DropColor;
    [self addActiveId];

}
//返回主界面
//-(void)back2Home{
//    HomeVC* homeVC = [[HomeVC alloc]init];
//    BaseNavigationController* nav = [[BaseNavigationController alloc]initWithRootViewController:homeVC];
//    [self presentViewController:nav animated:NO completion:nil];
//}
- (void)setAlertWithMsg:(NSString*)Msg{
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"啊哦" message:Msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(UITextField*)addTextField:(NSString* )placeholder PositionX:(CGFloat)x PositionY:(CGFloat)y Lenth:(CGFloat)l{
    UITextField* TextField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.centerX-x, self.view.centerY-y, l, 50)];
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

- (void)addActiveId{
    self.activeId = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeId.center = CGPointMake(self.view.centerX ,self.view.centerY+200);
    [self.view addSubview:self.activeId];
}

-(UIButton*)addButton:(NSString*) title PositionX:(CGFloat)x PositionY:(CGFloat)y{
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.centerX-x, self.view.centerY+y, 80, 50)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //btn.backgroundColor = DropColor;
    btn.layer.cornerRadius=20;
    //btn.enabled = NO;
    [btn addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

- (void)getStrCmdWithScodeText:(NSMutableString* )sCodeText{
    
    [sCodeText insertString:@"=" atIndex:0];
    //找到字母和数字分隔处
    for(int i = 0; i<sCodeText.length;i++){
        if('0' <=[sCodeText characterAtIndex:i]&&[sCodeText characterAtIndex:i]<= '9'){
            [sCodeText insertString:@"=" atIndex:i];
            break;
        }
    }
}

-(void)ButtonPressed:(id)sender{
    
    UIButton* btn = sender;
    
    if(self.ScodeTextField.text.length==0){
        [self setAlertWithMsg:@"二货,输入合约代码"];
    }
    else if(self.CountTextField.text.length==0){
        [self setAlertWithMsg:@"二货,你要买几手"];
    }
    else if(self.PriceTextField.text.length == 0){
        [self setAlertWithMsg:@"二货,什么价位买入"];
    }
    else {
        
        NSMutableString* sCodeText = [[NSMutableString alloc]initWithString:[self.ScodeTextField.text uppercaseString]];
        [self getStrCmdWithScodeText:sCodeText];
        if(btn.tag==500){
            NSLog(@"open");
            //开仓
            AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            NSString* orderRef =  [app.iceTool SendCmd:app.strCmd strCmdType:@"GetOrderRef"];
            //NSLog(@"orderRef = %@",orderRef);
            //        NSMutableString* sCodeText = [[NSMutableString alloc]initWithString:[self.ScodeTextField.text uppercaseString]];
            //        [self getStrCmdWithScodeText:sCodeText];
            [sCodeText appendString:@"=1=1="];
            [sCodeText appendString:self.PriceTextField.text];
            [sCodeText appendString:@"="];
            [sCodeText appendString:self.CountTextField.text];
            [sCodeText appendString:@"=9999=1"];//开仓
            //[sCodeText appendString:@"1"];//buy
            NSLog(@"scodetex = %@",sCodeText);
            NSString* strcmd = [[NSString alloc]initWithFormat:@"%@%@%@%@",app.strCmd,@"=",orderRef,sCodeText];
            @try{
                [app.iceTool SendOrder:strcmd];
            }
            @catch(ICEException* s){
                [self setAlertWithMsg:@"操作失败 请重试"];
            }
            [self setAlertWithMsg:@"操作成功"];
            self.CountTextField.text = nil;
            self.ScodeTextField.text = nil;
            self.PriceTextField.text = nil;
            
            
        }
        else if (btn.tag==501){
            
            NSLog(@"close");
            //self.CloseButton.enabled=YES;
            //开仓
            AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            NSString* orderRef =  [app.iceTool SendCmd:app.strCmd strCmdType:@"GetOrderRef"];
            //NSLog(@"orderRef = %@",orderRef);
            //        NSMutableString* sCodeText = [[NSMutableString alloc]initWithString:[self.ScodeTextField.text uppercaseString]];
            //        [self getStrCmdWithScodeText:sCodeText];
            [sCodeText appendString:@"=1=2="];//卖出
            [sCodeText appendString:self.PriceTextField.text];
            [sCodeText appendString:@"="];
            [sCodeText appendString:self.CountTextField.text];
            [sCodeText appendString:@"=9999=1"];//开仓
            //[sCodeText appendString:@"2"];//sell
            NSLog(@"scodetex = %@",sCodeText);
            NSString* strcmd = [[NSString alloc]initWithFormat:@"%@%@%@%@",app.strCmd,@"=",orderRef,sCodeText];
            @try{
                [app.iceTool SendOrder:strcmd];
            }
            @catch(ICEException* s){
                [self setAlertWithMsg:@"操作失败 请重试"];
            }
            [self setAlertWithMsg:@"操作成功"];
            self.CountTextField.text = nil;
            self.ScodeTextField.text = nil;
            self.PriceTextField.text = nil;
        }
        
        
        
    }
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    [textField resignFirstResponder];
////    if(textField.text.length>0)
////    {
////       self.OpenButton.enabled = YES;
////    }
////    else{
////         self.OpenButton.enabled = NO;
////    }
//
//    //NSLog(@"%@",textField.text);
//    return YES;
//}

@end
