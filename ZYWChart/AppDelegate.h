//
//  AppDelegate.h
//  ZYWChart
//
//  Created by 张有为 on 2016/12/17.
//  Copyright © 2016年 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICETool.h"
#import "LoginVC.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ICETool* iceTool;
@property (strong,nonatomic) NSString* userName;
@property (strong,nonatomic) NSString* passWord;
@property (strong,nonatomic) NSString* userID;
@property (strong,nonatomic) WpTradeAPIServerCallbackReceiverI* wpTradeAPIServerCallbackReceiverI;
@property (strong,nonatomic) LoginVC* loginVC;
@property (nonatomic) int loginFlag;
@property (strong,nonatomic) NSString* strCmd;
@end

