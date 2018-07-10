//
//  Y_KlineMAVLabelView.h
//  ZYWChart
//
//  Created by zdqh on 2018/7/10.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Y_KLineModel;
@interface Y_KlineMAVLabelView : UIView
+(instancetype)view;

-(void)maProfileWithModel:(Y_KLineModel *)model;
//-(void)addLabels;
@end
