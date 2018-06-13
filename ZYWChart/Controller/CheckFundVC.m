//
//  CheckFundVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/12.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "CheckFundVC.h"
#import "FundDataModel.h"
#import "FundDataModel.h"
@interface CheckFundVC ()<UITableViewDelegate,UITableViewDataSource>

//@property (nonatomic,strong)  UITableView    *tableView;
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
    [self addTableView];
    // Do any additional setup after loading the view.
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
    return [self.fundDataArray count]-1;
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
    
    NSString* currencyCode = [self.fundDataArray objectAtIndex:indexPath.row][6];
    NSString* Tmoney = [self.fundDataArray objectAtIndex:indexPath.row][37];
    NSString* Tbalance = [self.fundDataArray objectAtIndex:indexPath.row][38];
    NSString* TcanCashOut = [self.fundDataArray objectAtIndex:indexPath.row][39];
    NSString* riskRate = [self.fundDataArray objectAtIndex:indexPath.row][40];
    NSString* accountMarketValue = [self.fundDataArray objectAtIndex:indexPath.row][41];

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
