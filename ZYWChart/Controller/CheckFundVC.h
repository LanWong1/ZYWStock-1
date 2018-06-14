//
//  CheckFundVC.h
//  ZYWChart
//
//  Created by zdqh on 2018/6/12.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckFundVC : UIViewController
@property (nonatomic,copy) NSMutableArray* fundDataArray;
- (UILabel*)addLableWithName:(NSString*)name PositonX:(CGFloat)x PositionY:(CGFloat)y Type:(int)type;
@end
