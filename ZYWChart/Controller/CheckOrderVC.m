//
//  CheckOrderVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/13.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "CheckOrderVC.h"
#import "OrderDataModel.h"
@interface CheckOrderVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)  NSMutableArray<__kindof OrderDataModel*> *modleArray;

@end

@implementation CheckOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"委托";
    [self addLableWithName:@"商品代码" PositonX:0 PositionY:62 Type:0];
    [self addLableWithName:@"合约代码"  PositonX:70 PositionY:62 Type:0];
    [self addLableWithName:@"委托状态" PositonX:140 PositionY:62 Type:0];
    [self addLableWithName:@"成交价格" PositonX:210 PositionY:62 Type:0];
    [self addLableWithName:@"成交数量" PositonX:280 PositionY:62 Type:0];
    [self addLableWithName:@"委托价格" PositonX:70*5 PositionY:62 Type:0];
    self.modleArray = [NSMutableArray array];
    NSEnumerator* enumerator = [self.orderDataArray objectEnumerator];
    id obj = nil;
    while(obj = [enumerator nextObject]){
        NSArray * arry = obj;
        OrderDataModel *M = [[OrderDataModel alloc]init];
        M.CommodityNo = arry[6];
        M.ContractNo  = arry[7];
        M.OrderState  = arry[36];
        M.MatchPrice  = arry[37];
        M.MatchVol    = arry[38];
        M.OrderPrice  = arry[16];
        [self.modleArray addObject:M];
    }
    if([self.modleArray count] == 1){
        [self setAlertWithMessage:@"无委托"];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSString* OrderState = [self.modleArray objectAtIndex:indexPath.row].OrderState;
    NSString* MatchPrice = [self.modleArray objectAtIndex:indexPath.row].MatchPrice;
    NSString* MatchVol = [self.modleArray objectAtIndex:indexPath.row].MatchVol;
    NSString* OrderPrice = [self.modleArray objectAtIndex:indexPath.row].OrderPrice;
    
    [cell addSubview: [self addLableWithName:CommodityNo PositonX:0 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:ContractNo PositonX:70 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:OrderState PositonX:140 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:MatchPrice PositonX:210 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:MatchVol PositonX:280 PositionY:5 Type:1]];
    [cell addSubview:[self addLableWithName:OrderPrice PositonX:350 PositionY:5 Type:1]];
    return cell;
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
