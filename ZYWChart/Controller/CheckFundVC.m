//
//  CheckFundVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/12.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "CheckFundVC.h"
#import "FundDataModel.h"

@interface CheckFundVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)  NSMutableArray<__kindof FundDataModel*> *modleArray;
@end

@implementation CheckFundVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"资金";
    
    
    
    
    [self addLableWithName:@"货币编号" PositonX:0 PositionY:62 Type:0];
    [self addLableWithName:@"今资金"  PositonX:70 PositionY:62 Type:0];
    [self addLableWithName:@"今权益" PositonX:140 PositionY:62 Type:0];
    [self addLableWithName:@"今可提" PositonX:210 PositionY:62 Type:0];
    [self addLableWithName:@"风险率" PositonX:280 PositionY:62 Type:0];
    [self addLableWithName:@"账户市值" PositonX:70*5 PositionY:62 Type:0];
    self.modleArray = [NSMutableArray array];
    NSEnumerator* enumerator = [self.fundDataArray objectEnumerator];
    id obj = nil;
    while(obj = [enumerator nextObject]){
        NSArray * arry = obj;
        FundDataModel *M = [[FundDataModel alloc]init];
        M.CurrencyNo = arry[6];
        M.TMoney     = arry[37];
        M.TBalance   = arry[38];
        M.TCanCashOut = arry[39];
        M.RiskRate   = arry[40];
        M.AccountMarketValue = arry[41];
        [self.modleArray addObject:M];
    }
    if([self.modleArray count] == 1){
        [self setAlertWithMessage:@"无资金"];
    }
    [self addTableView];
    // Do any additional setup after loading the view.
}
- (void)setAlertWithMessage:(NSString*)msg{
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:@"警告"
                                                                 message:msg
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (UILabel*)addLableWithName:(NSString*)name PositonX:(CGFloat)x PositionY:(CGFloat)y Type:(int)type {
    UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(x, y, 70, 40)];
    lable.text = name;
    lable.textAlignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont systemFontOfSize:13];
    [lable setFont:font];
    if(type==0){
        lable.backgroundColor = RoseColor;
        [self.view addSubview:lable];
    }
    else{
        lable.backgroundColor = [UIColor whiteColor];
    }
    return lable;
}

//tableview
- (void)addTableView{
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, DEVICE_WIDTH,DEVICE_HEIGHT)];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return [self.modleArray count]-1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"dddddd");
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
    
    NSString* currencyCode = [self.modleArray objectAtIndex:indexPath.row].CurrencyNo;
    NSString* Tmoney = [self.modleArray objectAtIndex:indexPath.row].TMoney;
    NSString* Tbalance = [self.modleArray objectAtIndex:indexPath.row].TBalance;
    NSString* TcanCashOut = [self.modleArray objectAtIndex:indexPath.row].TCanCashOut;
    NSString* riskRate = [self.modleArray objectAtIndex:indexPath.row].RiskRate;
    NSString* accountMarketValue = [self.modleArray objectAtIndex:indexPath.row].AccountMarketValue;
    [cell addSubview: [self addLableWithName:currencyCode PositonX:0 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:Tmoney PositonX:70 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:Tbalance PositonX:140 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:TcanCashOut PositonX:210 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:riskRate PositonX:280 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:accountMarketValue PositonX:350 PositionY:5 Type:1]];
    return cell;
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

@end
