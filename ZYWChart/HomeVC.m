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
#import "CodeListVC.h"
#import "TimeLineVC.h"
#import "BuyVC.h"
#import "WpTrade.h"
#import "LoginVC.h"
#import "ICEQuote.h"

//@interface WpQuoteServerCallbackReceiverI : WpQuoteServerCallbackReceiver<WpQuoteServerCallbackReceiver>
//@end
//
//@implementation WpQuoteServerCallbackReceiverI
//- (void)SendMsg:(ICEInt)itype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current
//{
//    NSLog(@"%@",strMessage);
//}
//@end

@interface HomeVC () 

@property (nonatomic) ICEQuote* iceQuote;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIActivityIndicatorView *activeId;
@property (nonatomic,strong) UIButton *homeButton;
@property (nonatomic,strong) UIButton *getTimeLineBtn;
@property (nonatomic)        ICEInt iRet;
@property (nonatomic,strong) UISearchBar *search;
@property (nonatomic,copy)   NSArray* searchResult;
@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic) CodeListVC *historyVC;
@property (nonatomic) LoginVC *loginVC;
@property (nonatomic) int connectFlag;

//ICE
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<WpQuoteServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic) id<WpQuoteServerClientApiPrx> WpQuoteServerclientApiPrx;
@property (nonatomic) WpQuoteServerDayKLineList *KlineList;
@end

@implementation HomeVC




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"主页";
    UINavigationBar.appearance.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    UIButton *lineButton  = [self addBtn:@"看行情" y_Position:self.view.centerY-200];//添加按钮
    lineButton.enabled = NO;
    UIButton *buyButton   = [self addBtn:@"交易" y_Position:self.view.centerY+100];
    lineButton.tag = 1000;
    buyButton.tag  = 1000+1;
    [self.view addSubview:lineButton];
    [self.view addSubview: buyButton];
    [self connect2Server];
}

//conncet to server
- (void) connect2Server{
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
                UIButton *lineButton=[self addBtn:@"看行情" y_Position:self.view.centerY-200];//添加按钮
                UIButton *buyButton = [self addBtn:@"交易" y_Position:self.view.centerY+100];
                lineButton.tag = 1000;
                buyButton.tag  = 1000+1;
                [self.view addSubview:lineButton];
                [self.view addSubview: buyButton];
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
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.centerX-80, self.view.centerY-200, 160, 20)];
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.text = @"Connect to server,Please wait";
    [self.view addSubview:self.label];
}
- (UIButton*)addBtn:(NSString*)name y_Position:(CGFloat)Y
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = RoseColor;
    btn.layer.cornerRadius=20;
    btn.frame = CGRectMake(self.view.centerX-50, Y, 100, 50);
    [btn setTitle:name forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
    //[self.view addSubview:self.homeButton];
}



//getData
- (void)btnPress:(id)sender{
    
    UIButton* btn = sender;
    if(btn.tag==1000){
        
        if(self.historyVC == nil){
            self.historyVC = [[CodeListVC alloc]init];
            [self.historyVC activate:self.iceQuote];
        }
//        UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:_historyVC];
//        [self presentViewController:nav animated:NO completion:nil];
        [self.navigationController pushViewController:self.historyVC animated:NO];
    }
    else if(btn.tag==1001){
        if(self.loginVC == nil){
            self.loginVC = [[LoginVC alloc]init];  
        }
        [self.navigationController pushViewController:self.loginVC animated:NO];
    }
}
@end
