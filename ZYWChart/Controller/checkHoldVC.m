//
//  checkHoldVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/14.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "checkHoldVC.h"
#import "HoldDataModel.h"

@interface checkHoldVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)  NSMutableArray<__kindof HoldDataModel*> *modleArray;
@end

@implementation checkHoldVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"持仓";
    [self addLableWithName:@"商品编号" PositonX:0 PositionY:62 Type:0];
    [self addLableWithName:@"合约号"  PositonX:70 PositionY:62 Type:0];
    [self addLableWithName:@"买卖方向" PositonX:140 PositionY:62 Type:0];
    [self addLableWithName:@"持仓量" PositonX:210 PositionY:62 Type:0];
    [self addLableWithName:@"保证金" PositonX:280 PositionY:62 Type:0];
    [self addLableWithName:@"昨结算价" PositonX:70*5 PositionY:62 Type:0];
    self.modleArray = [NSMutableArray array];
   NSEnumerator* enumerator = [self.holdDataArray objectEnumerator];
    id obj = nil;
    while(obj = [enumerator nextObject]){
        NSArray * arry = obj;
        HoldDataModel *M = [[HoldDataModel alloc]init];
        M.CommodityNo = arry[7];
        M.ContractNo = arry[8];
        M.Direct = arry[9];
        M.TradeVol = arry[12];
        M.YSettlePrice = arry[13];
        M.Deposit = arry[17];
        [self.modleArray addObject:M];
    }
    if([self.modleArray count] == 1){
        [self setAlertWithMessage:@"无持仓"];
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
    
    NSString* CommodityNo = [self.modleArray objectAtIndex:indexPath.row].CommodityNo;
    NSString* ContractNo = [self.modleArray objectAtIndex:indexPath.row].ContractNo;
    NSString* Direct = [self.modleArray objectAtIndex:indexPath.row].Direct;
    NSString* TradeVol = [self.modleArray objectAtIndex:indexPath.row].TradeVol;
    NSString* Deposit = [self.modleArray objectAtIndex:indexPath.row].Deposit;
    NSString* YSettlePrice = [self.modleArray objectAtIndex:indexPath.row].YSettlePrice;
    [cell addSubview: [self addLableWithName:CommodityNo PositonX:0 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:ContractNo PositonX:70 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:Direct PositonX:140 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:TradeVol PositonX:210 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:Deposit PositonX:280 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:YSettlePrice PositonX:350 PositionY:5 Type:1]];
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



