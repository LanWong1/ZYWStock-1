//
//  CheckFundVC.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/12.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "CheckFundVC.h"

@interface CheckFundVC ()

@end

@implementation CheckFundVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"资金";
    [self addLableWithName:@"货币编号" PositonX:0 ];
    [self addLableWithName:@"今资金" PositonX:70 ];
    [self addLableWithName:@"今权益" PositonX:140 ];
    [self addLableWithName:@"今可提" PositonX:210 ];
    [self addLableWithName:@"风险率" PositonX:280];
    [self addLableWithName:@"账户市值" PositonX:70*5];
    // Do any additional setup after loading the view.
}
- (void)addLableWithName:(NSString*)name PositonX:(CGFloat)x {
    UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(x, 70, 70, 30)];
    lable.text = name;
    lable.textAlignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont systemFontOfSize:12];
    [lable setFont:font];
    lable.backgroundColor = RoseColor;
    [self.view addSubview:lable];
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
