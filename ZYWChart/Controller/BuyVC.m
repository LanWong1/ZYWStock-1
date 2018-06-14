//
//  BuyVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/5.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "BuyVC.h"
#import "ICETool.h"
#import "CheckFundVC.h"
#import "BaseNavigationController.h"
#import "HomeVC.h"
#import "CheckOrderVC.h"
#import "AppDelegate.h"
#import "checkHoldVC.h"

@interface BuyVC ()<UITextFieldDelegate>

@property (nonatomic,strong)  UIButton *buyButton;
@property (nonatomic,strong)  UITextField *ScodeTextField;
@property (nonatomic,strong)  UITextField *CountTextField;
@property (nonatomic,strong)  UIButton *OpenButton;
@property (nonatomic,strong)  UIButton *CloseButton;
@property (nonatomic,strong)  UIButton *QueryButton;
@property (nonatomic,strong)  UIButton *FundButton;
@property (nonatomic,strong)  UIButton *HoldButton;
@property (nonatomic) NSString* loginStrCmd;
@property (nonatomic) ICETool* iceTool;
@property (nonatomic) WpTradeAPIServerCallbackReceiverI* wpTradeAPIServerCallbackReceiverI;
@property (nonatomic) NSMutableArray* Msg;
@property (nonatomic,strong)  UIActivityIndicatorView *activeId;
@property (nonatomic) CheckFundVC* checkFundVC;

@end

@implementation BuyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"交易";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"行情" style:UIBarButtonItemStylePlain target:self action:@selector(back2Home)];
    self.ScodeTextField = [self addTextField:@"合约代码" PositionX:100 PositionY:150];
    self.CountTextField = [self addTextField:@"手数" PositionX:100 PositionY:100];
    
    self.OpenButton = [self addBuyButton:@"开仓" PositionX:110 PositionY:-10];
    self.OpenButton.tag = 500;
    
    self.CloseButton = [self addBuyButton:@"平仓" PositionX:-30 PositionY:-10];
    self.CloseButton.tag = 500+1;
    
    self.QueryButton = [self addBuyButton:@"查委托" PositionX:110 PositionY:80];
    self.QueryButton.tag = 502;
    
    self.FundButton = [self addBuyButton:@"查资金" PositionX:-30 PositionY:80];
    self.FundButton.tag = 503;
    
    self.HoldButton = [self addBuyButton:@"查持仓" PositionX:110 PositionY:170];
    self.HoldButton.tag = 504;
    
    [self addActiveId];
 
    
    // Do any additional setup after loading the view.
}
//返回主界面
-(void)back2Home{
    HomeVC* homeVC = [[HomeVC alloc]init];
    BaseNavigationController* nav = [[BaseNavigationController alloc]initWithRootViewController:homeVC];
    [self presentViewController:nav animated:NO completion:nil];
}

-(UITextField*)addTextField:(NSString* )placeholder PositionX:(CGFloat)x PositionY:(CGFloat)y{
    UITextField* TextField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.centerX-x, self.view.centerY-y, 200, 50)];
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

-(UIButton*)addBuyButton:(NSString*) title PositionX:(CGFloat)x PositionY:(CGFloat)y {
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.centerX-x, self.view.centerY+y, 80, 50)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    btn.backgroundColor = RoseColor;
    btn.layer.cornerRadius=20;
    //btn.enabled = NO;
    [btn addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

-(void)ButtonPressed:(id)sender{
    UIButton* btn = sender;
    if(btn.tag==500){
        NSLog(@"open");
        self.CloseButton.enabled=YES;
        if(self.ScodeTextField.text.length==0){
            UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"Erro" message:@"合约代码不能为空" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"ssss");
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if(self.CountTextField.text.length==0){
            UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"Erro" message:@"合约数不能为空" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];//^(UIAlertAction * _Nonnull action) {
               // NSLog(@"ssss");
            //}]];
            [self presentViewController:alert animated:YES completion:nil];  
        }
    }
    else if (btn.tag==501){
        NSLog(@"close");
        self.CloseButton.enabled=NO;
    }
    else if(btn.tag==502){
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [app.iceTool queryOrder:app.strCmd];
        [self.activeId startAnimating];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addCheckOrderVC) userInfo:nil repeats:NO];
    }
    else if(btn.tag == 503)
    {
       AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
       [app.iceTool queryFund:app.strCmd];
       [self.activeId startAnimating];
       [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addCheckFundVC) userInfo:nil repeats:NO];
    }
    else if(btn.tag == 504)
    {
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [app.iceTool queryHold:app.strCmd];
        [self.activeId startAnimating];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addCheckHoldVC) userInfo:nil repeats:NO];
    }
}
- (void)addCheckOrderVC{
    [self getMSg];
    CheckOrderVC* orderVC = [[CheckOrderVC alloc]init];
    orderVC.orderDataArray=self.Msg;
    [self.navigationController pushViewController:orderVC animated:NO];
    [self.activeId stopAnimating];
}
- (void)addCheckHoldVC{
    [self getMSg];
    checkHoldVC* orderVC = [[checkHoldVC alloc]init];
    orderVC.holdDataArray=self.Msg;
 
    [self.navigationController pushViewController:orderVC animated:NO];
    [self.activeId stopAnimating];
}
- (void)addCheckFundVC{
    [self getMSg];
    self.checkFundVC = [[CheckFundVC alloc]init];
    self.checkFundVC.fundDataArray=self.Msg;
    [self.navigationController pushViewController:self.checkFundVC animated:NO];
    [self.activeId stopAnimating];
}

- (void)getMSg{
    
    self.Msg = [NSMutableArray array];
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSEnumerator *enumerator = [[app.wpTradeAPIServerCallbackReceiverI messageForBuyVC] objectEnumerator];
    id obj = nil;
    while (obj = [enumerator nextObject]){
        NSMutableString *Message = [[NSMutableString alloc]initWithCapacity:0];
        Message = obj;
        NSArray* arry=[Message componentsSeparatedByString:@"="];
        [self.Msg addObject:arry];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//    if(textField.text.length>0)
//    {
//       self.OpenButton.enabled = YES;
//    }
//    else{
//         self.OpenButton.enabled = NO;
//    }
//
//    //NSLog(@"%@",textField.text);
//    return YES;
//}

@end
