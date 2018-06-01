//
//  TimeLineVC.m
//  ZYWChart
//
//  Created by 张有为 on 2017/5/5.
//  Copyright © 2017年 zyw113. All rights reserved.
//

#import "TimeLineVC.h"
#import "ZYWTimeLineView.h"

@interface TimeLineVC ()

@property (nonatomic,strong) ZYWTimeLineView *timeLineView;

@end

@implementation TimeLineVC

- (void)viewDidLoad {
    [super viewDidLoad];
   // Do any additional setup after loading the view.
    self.navigationItem.title  = self.sCode;
    self.view.backgroundColor = [UIColor whiteColor];
    _timeLineView = [ZYWTimeLineView new];
    _timeLineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_timeLineView];
    [_timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(200));
        make.top.equalTo(@(100));
    }];
    [_timeLineView layoutIfNeeded];
    
    
    
//    NSString * path =[[NSBundle mainBundle]pathForResource:@"data.plist" ofType:nil];
//    NSArray * sourceArray = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:@"data3"];
//    for (NSDictionary * dic in sourceArray) {
//        ZYWTimeLineModel * e = [[ZYWTimeLineModel alloc]init];
//        e.currtTime = dic[@"curr_time"];
//        e.preClosePx = [dic[@"pre_close_px"] doubleValue];
//        e.avgPirce = [dic[@"avg_pirce"] doubleValue];
//        e.lastPirce = [dic[@"last_px"]doubleValue];
//        e.volume = [dic[@"last_volume_trade"]doubleValue];
//        e.rate = dic[@"rise_and_fall_rate"];
//        [timeArray addObject:e];
//    }
    if([self.timeData count]>0)
    {
        NSMutableArray * timeArray = [NSMutableArray array];
        //[self.timeData removeLastObject];
        NSEnumerator *enumerator =[self.timeData objectEnumerator];
        id obj = nil;
        while (obj = [enumerator nextObject]){
            NSString *string = obj;
            NSArray* array1 = [string componentsSeparatedByString:@","];
            ZYWTimeLineModel * e = [[ZYWTimeLineModel alloc]init];
            e.currtTime = array1[1];
            e.preClosePx = [array1[6] doubleValue];
            e.avgPirce = 0;
            e.lastPirce = [array1[3] doubleValue];
            e.volume = [array1[7] doubleValue];
            e.rate = array1[8];
            [timeArray addObject:e];
        }
        _timeLineView.leftMargin =10;
        _timeLineView.rightMargin  = 10;
        _timeLineView.lineColor = [UIColor redColor];
        //_timeLineView.fillColor = [UIColor colorWithHexString:@"2828ff"];
        _timeLineView.fillColor = [UIColor whiteColor];
        _timeLineView.timesCount = 243;
        _timeLineView.dataArray = timeArray.mutableCopy;
        [_timeLineView stockFill];
    }
    else{
        //NSLog(@"ssssssss"); //弹窗警告
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

@end
