//
//  ICEQuote.m
//  ZYWChart
//
//  Created by zdqh on 2018/6/11.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "ICEQuote.h"
#import <objc/Ice.h>
#import <objc/Glacier2.h>
#import "QuoteModel.h"
#import "QuoteArrayModel.h"


@interface WpQuoteServerCallbackReceiverI()<WpQuoteServerCallbackReceiver>
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic,strong)  NSMutableArray<__kindof QuoteModel*> *quoteModelArray;
@end

@implementation WpQuoteServerCallbackReceiverI

- (void)SendMsg:(ICEInt)itype strMessage:(NSMutableString *)strMessage current:(ICECurrent *)current
{
    if(itype == 1){
        NSLog(@"订阅消息 type:%d  strmessage = %@",itype,strMessage);
        NSArray* arr =  [strMessage componentsSeparatedByString:@","];
        NSLog(@"index =======   %@",[QuoteArrayModel shareInstance].codelistDic[arr[1]]) ;
        
        QuoteModel* model = [[QuoteModel alloc] init];
        [model processWithArray:arr];
        
        
//        if(_delegate && [_delegate respondsToSelector:@selector(reloadData:)]){
//            NSLog(@"调用代理 回调");
//            [_delegate reloadData:[[QuoteArrayModel shareInstance].codelistDic[arr[1]] integerValue] ];
//        }
        
        
        
        //NSString *type = [NSString stringWithFormat:@"%d",itype];
        // [QuoteModel shareInstance];
        // [self dataProcess:arr];
        if([QuoteArrayModel shareInstance].codelistDic[arr[1]]){
            
           
             [[NSNotificationCenter defaultCenter] postNotificationName:@"quoteNotity" object:self userInfo:@{@"index":[QuoteArrayModel shareInstance].codelistDic[arr[1]],@"model":model}];
        }
       
        //[self setHeartbeat];
    }

 
    
    
}
/*
-(void)dataProcess:(NSArray*)strMessage{
    
    if(!_quoteModelArray){
        _quoteModelArray = [NSMutableArray array];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        
        __block NSInteger findModelIdx = 0;
        if(_quoteModelArray.count>0){
            NSLog(@"开始遍历_quoteModelArray");
            [_quoteModelArray enumerateObjectsUsingBlock:^(__kindof QuoteModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"obj.instrumentID ===== %@   message = ==  %@",obj.instrumenID,strMessage[1]);
                //array中包含了此合约的model
                if([obj.instrumenID isEqualToString:strMessage[1]]){
                    
                    obj.lastPrice = strMessage[4];//最新价
                    obj.openInterest = strMessage[13];//持仓量
                    obj.preSettlementPrice = strMessage[5];
                    [obj calculatePriceChange];//涨幅
                    findModelIdx = idx;
                    NSLog(@"findmodel index  ===== %ld",idx);
                    *stop = YES;
                }
                //遍历完没有找到相同的合约号 遍历到最后一个
                if((idx== _quoteModelArray.count-1) && (findModelIdx!= _quoteModelArray.count-1)){
                    QuoteModel *model = [[QuoteModel alloc]initWithArray:strMessage];
                    [_quoteModelArray addObject:model];
                    findModelIdx = _quoteModelArray.count - 1;
                    NSLog(@"findmodel index+++++++++++ ===== %ld",(long)findModelIdx);
                }
                
            }];
        }
        else{
            NSLog(@"第一组数据开始++++++++++");
            QuoteModel *model = [[QuoteModel alloc]initWithArray:strMessage];
            [_quoteModelArray addObject:model];
        }
        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            //代理通知 找到第几个cell需要改变。合约顺序不变
//            if(_delegate && [_delegate respondsToSelector:@selector(reloadData: index:)]){
//                NSLog(@"findmodel index ===== %ld",(long)findModelIdx);
//                [_delegate reloadData:_quoteModelArray index:findModelIdx];
//            }
//            if(_delegate && [_delegate respondsToSelector:@selector(quoteViewRefresh:)]){
//                [_delegate quoteViewRefresh:_quoteModelArray];
//            }
//        });
    });
}
 */
//- (void)setHeartbeat{
//    // 创建GCD定时器
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 3 * NSEC_PER_SEC, 0); //每3秒执行
//    // 事件回调
//    dispatch_source_set_event_handler(_timer, ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"quoteNotity" object:self userInfo:@{@"message":@"jjkkkjkjk",@"type":@(5)}];
//
//    });
//    // 开启定时器
//    dispatch_resume(_timer);
//}
@end

@interface ICEQuote()
@property (nonatomic) id<ICECommunicator> communicator;
@property (nonatomic) id<WpQuoteServerCallbackReceiverPrx> twowayR;
@property (nonatomic) id<GLACIER2RouterPrx> router;
@property (nonatomic)  WpQuoteServerCallbackReceiverI* wpQuoteServerCallbackReceiverI;
//@property (nonatomic) WpQuoteServerDayKLineList* DLL;
//@property (nonatomic) NSTimer *timer;
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic) id<ICEConnection> connection;
@end

@implementation ICEQuote


static ICEQuote* iceQuote = nil;

+ (ICEQuote*)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (iceQuote == nil){
            iceQuote = [[self alloc]init];
        }
    });
    return iceQuote;
}

- (WpQuoteServerCallbackReceiverI*)Connect2Quote{
    
    
    if(self.router){
        
        @try{
            [self.router destroySession];
        }
        @catch(ICEException *s){
            
        }
        self.router = nil;
    }
    if(self.communicator){
        
        @try{
            [self.communicator destroy];
        }
        @catch(ICEException *s){
            NSLog(@"erro = %@",s);
        }
        self.communicator = nil;
    }
    if(self.connection){
        
        @try{
            [self.connection close:ICEConnectionCloseForcefully];
        }
        @catch(ICEException *s){
            NSLog(@"erro = %@",s);
        }
    }
    
    
    
    ICEInitializationData* initData = [ICEInitializationData initializationData];
    initData.properties = [ICEUtil createProperties];
    [initData.properties load:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"config1.client"]];
    
    initData.dispatcher = ^(id<ICEDispatcherCall> call, id<ICEConnection> con)
    {
        dispatch_sync(dispatch_get_main_queue(), ^ { [call run]; });
    };
    self.communicator = [ICEUtil createCommunicator:initData];//创建communicator
    //连接
    self.router = [GLACIER2RouterPrx checkedCast:[self.communicator getDefaultRouter]];//路由
    [self.router createSession:@"" password:@""];//创建session
    self.connection =  [self.router ice_getConnection];
    self.WpQuoteServerclientApiPrx = [WpQuoteServerClientApiPrx uncheckedCast:[self.communicator stringToProxy:@"ClientApiId"]];//返回具有所请求类型代理
    //启用主推回报
    ICEIdentity* callbackReceiverIdent= [ICEIdentity identity:@"callbackReceiver" category:[self.router getCategoryForClient]];
    id<ICEObjectAdapter> adapter = [self.communicator createObjectAdapterWithRouter:@"" router:self.router];
    [adapter activate];
    self.wpQuoteServerCallbackReceiverI = [[WpQuoteServerCallbackReceiverI alloc]init];
    self.twowayR = [WpQuoteServerCallbackReceiverPrx uncheckedCast:[adapter add:_wpQuoteServerCallbackReceiverI identity:callbackReceiverIdent]];

    return self.wpQuoteServerCallbackReceiverI;
}

- (WpQuoteServerDayKLineList*)GetDayKline:(NSString*) ExchangeID{
    NSString* strErr2 = @"";
    WpQuoteServerDayKLineList* DLL = [[WpQuoteServerDayKLineList alloc]init];
    NSMutableString* sExchangeID = [[NSMutableString alloc]initWithString:ExchangeID];
    @try{
        [self.WpQuoteServerclientApiPrx GetDayKLine:sExchangeID DKLL:&DLL strErrInfo:&strErr2];
    }
    @catch(ICEException* s)
    {
        NSLog(@"%@",s);
    }
    return DLL;
}

- (void)initiateCallback:(NSString*)strAcc{
    
    [self.WpQuoteServerclientApiPrx initiateCallback:strAcc proxy:self.twowayR];
}

- (void)Login:(NSString*)StrCmd{
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    int ret = [self.WpQuoteServerclientApiPrx Login:@"" strCmd:StrCmd strOut:&strOut strErrInfo:&strErroInfo];
    NSLog(@"login======== ===== %d",ret);
   // [self setHeartbeat];//设置心跳
}




- (int)HeartBeat:(NSString*)strCmd{
    
    int iRet = -2;
    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    iRet = [self.WpQuoteServerclientApiPrx HeartBeat:@"" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
    NSLog(@"quote heart beat iRet ==== %d",iRet);
    
    return iRet;
}



- (void)SubscribeQuote:(NSString *)strCmdType strCmd:(NSString *)strcmd{
//    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//    NSLog(@" strcmd == %@",strcmd);
//    int ret = [self.WpQuoteServerclientApiPrx SubscribeQuote:strCmdType strCmd:strcmd strOut:&strOut strErrInfo:&strErroInfo];
//    NSLog(@"ret ======= %d erro ====== %@  strout======= %@",ret,strErroInfo,strOut);
    @try{
        NSLog(@"开始订阅!!strCmdType = %@ strcmd = %@ ",strCmdType,strcmd);
        [self.WpQuoteServerclientApiPrx begin_SubscribeQuote:strCmdType strCmd:strcmd response:^(ICEInt i, NSMutableString *string, NSMutableString *string2) {
           NSLog(@"ret========%d string======%@ string======%@",i, string, string2);
        } exception:^(ICEException *s) {
            NSLog(@"%@订阅失败 原因 %@",strcmd, s);
        }];
    }
    @catch(NSException* s)
    {
        NSLog(@"订阅出错啦 %@",s);
    }
}



- (void)UnSubscribeQuote:(NSString *)strCmdType strCmd:(NSString *)strcmd{
//    NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//    NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
    
//        NSMutableString* strOut = [[NSMutableString alloc]initWithString:@""];
//        NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//        NSLog(@" strcmd == %@",strcmd);
//        int ret = [self.WpQuoteServerclientApiPrx UnSubscribeQuote:strCmdType strCmd:strcmd strOut:&strOut strErrInfo:&strErroInfo];
//        NSLog(@"ret ======= %d erro ====== %@  strout======= %@",ret,strErroInfo,strOut);
   
    
    @try{
        
        NSLog(@"unsubscribe++++++++++");
        [self.WpQuoteServerclientApiPrx begin_UnSubscribeQuote:strCmdType strCmd:strcmd response:^(ICEInt i, NSMutableString *string, NSMutableString *string2) {
            //NSLog(@"i===== %d s=====%@ s2=======%@",i, string, string2);
        } exception:^(ICEException *s) {
            NSLog(@"取消订阅失败 %@",s);
        }];
    }
    @catch(ICEException* s)
    {
        NSLog(@"%@",s);
    }
}


//获取timedata
//- (NSMutableArray*)getTimeData:(NSString*)sCode {
//    @try{
//        NSMutableString* strOut = [[NSMutableString alloc]init];
//        NSString* Code = sCode;
//        NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
//        [self.WpQuoteServerclientApiPrx GetKLine:@"day" strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
//        NSMutableArray* array = [NSMutableArray array];
//        if([strOut length]> 0){
//            array = [NSMutableArray array];
//            array = [[strOut componentsSeparatedByString:@"|"] mutableCopy];
//            [array removeLastObject];
//        }
//        else{
//            array = nil;
//        }
//        return array;
//    }
//    @catch(ICEException* s)
//    {
//        NSLog(@"Fail %@",s);
//    }
//}
//获取data
- (NSMutableArray*)getKlineData:(NSString*)strCmd type:(NSString*)type{
    @try{
        NSMutableString* strOut = [[NSMutableString alloc]init];
        NSMutableString* strErroInfo = [[NSMutableString alloc]initWithString:@""];
        
        [self.WpQuoteServerclientApiPrx GetKLine:type strCmd:strCmd strOut:&strOut strErrInfo:&strErroInfo];
        
        NSMutableArray* array = [NSMutableArray array];
        if([strOut length]> 0){
            
            array = [NSMutableArray array];
            array = [[strOut componentsSeparatedByString:@"|"] mutableCopy];
            [array removeLastObject];
        }
        else{
            NSLog(@"无数据!!!");
        }
        return array;
    }
    @catch(ICEException* s)
    {
        NSLog(@"Fail %@",s);
    }
}


@end
