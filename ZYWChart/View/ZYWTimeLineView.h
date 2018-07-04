//
//  ZYWTimeLineView.h
//  ZYWChart
//
//  Created by 张有为 on 2017/5/11.
//  Copyright © 2017年 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYWTimeLineModel.h"

@protocol ZYWTimeLineViewDataSource<NSObject>
- (NSString*)getString;
@end


@interface ZYWTimeLineView : ZYWBaseChartView

@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,assign) NSInteger timesCount;
@property (nonatomic,strong) UIColor *fillColor;
@property (nonatomic,strong) NSArray<__kindof ZYWTimeLineModel*> *dataArray;
@property (nonatomic, weak) id<ZYWTimeLineViewDataSource>dataSource;
//@property (nonatomic) int flag;
-(void)stockFill;
- (void)startRedraw;

@end
