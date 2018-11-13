//
//  CodeListViewController.m
//  ZYWChart
//
//  Created by IanWong on 2018/11/13.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "CodeListViewController.h"
#import "QuickOrderCodeListVCViewController.h"
@interface CodeListViewController ()
@property (strong, nonatomic) QuickOrderCodeListVCViewController *mainListVC;

@end

@implementation CodeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   
    UIButton *collectBtn =[self buttonWithTitle:@"自选" loacationX:50];
    UIButton *mainBtn = [self buttonWithTitle:@"主力" loacationX:0];
    [self addSegment];
//    [self.navigationController.navigationBar addSubview: collectBtn];
//    [self.navigationController.navigationBar addSubview: mainBtn];
    // Do any additional setup after loading the view.
}

- (void)addSegment{
    NSArray *title = [NSArray arrayWithObjects:@"自选",@"主力", nil];
    UISegmentedControl * segment = [[UISegmentedControl alloc]initWithItems:title];
    segment.selectedSegmentIndex = 1;
    
    [segment setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    
  
       segment.frame = CGRectMake(self.view.centerX-50, self.navigationController.navigationBar.centerY-50, 100, 40);
 

  [self.navigationController.navigationBar addSubview: segment];
    [segment addTarget:self action:@selector(touchSegment:) forControlEvents:UIControlEventValueChanged];
}
-(void)touchSegment:(UISegmentedControl*)segment{
    
    switch(segment.selectedSegmentIndex){
        case 0:
            NSLog(@"委托");
           // [self queryOrder];
            break;
        case 1:
            NSLog(@"持仓");
            if(!_mainListVC){
                _mainListVC = [[QuickOrderCodeListVCViewController alloc]init];
            }
            [self presentViewController:_mainListVC animated:YES completion:nil];
            break;
        default:
            break;
    }
}
- (UIButton *)buttonWithTitle:(NSString*)title loacationX:(float)x{
    static int i;
    i++;
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.centerX-x, self.navigationController.navigationBar.centerY-30, 50, 30)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:RoseColor forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTintColor:RoseColor];
    [btn setBackgroundColor:DropColor];
    btn.tag = 100+i;
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)btnPressed:(UIButton*)btn{
    if(btn.tag == 102){
        if(!_mainListVC){
            _mainListVC = [[QuickOrderCodeListVCViewController alloc]init];
        }
        [self presentViewController:_mainListVC animated:YES completion:nil];
    }
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
