//
//  CandleCrossScreenVC.m
//  ZYWChart
//
//  Created by 张有为 on 2017/5/9.
//  Copyright © 2017年 zyw113. All rights reserved.
//

#import "CandleCrossScreenVC.h"
#import "ZYWCandleChartView.h"
#import "ZYWCandleModel.h"
#import "ZYWTecnnicalView.h"
#import "ZYWMacdView.h"
#import "ZYWCalcuteTool.h"
#import "ZYWKdjLineView.h"
#import "ZYWWrLineView.h"
#import "ZYWPriceView.h"
#import "ZYWCrossPriceView.h"
#import "ZYWCandleProtocol.h"
#import "UIView+Extension.h"
#import "ZYWCandlePostionModel.h"
#import "ZYWTimeLineView.h"
typedef enum
{
    MACD = 1,
    KDJ,
    WR
}DataLineType;

#define ScrollScale 0.98
#define CandleChartScale 0.6
#define TechnicalViewScale 0.1
#define BottomViewScale 0.28
#define MinCount 10
#define MaxCount 200

@interface CandleCrossScreenVC () <NSXMLParserDelegate,ZYWCandleProtocol,ZYWTecnnicalViewDelegate>
@property (nonatomic,strong) ZYWCrossPriceView *quotaView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) ZYWCandleChartView *candleChartView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) ZYWCandleModel *model;
@property (nonatomic,strong) UIView *topBoxView;
@property (nonatomic,strong) UIView *bottomBoxView;
@property (nonatomic,strong) ZYWTecnnicalView *technicalView;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,assign) DataLineType type;
@property (nonatomic,strong) ZYWMacdView *macdView;
@property (nonatomic,strong) ZYWKdjLineView *kdjLineView;
@property (nonatomic,strong) ZYWWrLineView *wrLineView;
@property (nonatomic,strong) ZYWPriceView *topPriceView;
@property (nonatomic,strong) ZYWPriceView *bottomPriceView;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic,strong) UIPinchGestureRecognizer *pinchPressGesture;
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic,strong) UIView *verticalView;
@property (nonatomic,strong) UIView *leavView;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) NSUInteger zoomRightIndex;
@property (nonatomic, assign) CGFloat currentZoom;
@property (nonatomic, assign) NSInteger displayCount;
@property (nonatomic, copy) NSString* sCode;
@property (nonatomic, copy) WpQuoteServerDayKLineList* KlineData;
@property (nonatomic, strong) NSArray* timeData;
@property (nonatomic,strong) UIButton* klineBtn;
@property (nonatomic,strong) UIButton* TlineBtn;
@property (nonatomic,strong) ZYWTimeLineView *timeLineView;
@property (nonatomic,strong) UIView *timeLineBoxView;
@end

@implementation CandleCrossScreenVC

#pragma mark ------

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    basicAnimation.fromValue = @(-M_PI_4);
    basicAnimation.toValue = @(0);
    basicAnimation.removedOnCompletion = YES;
    basicAnimation.fillMode = kCAFillModeForwards;
    [self.view.layer addAnimation:basicAnimation forKey:nil];
}
#pragma mark 初始化
-(instancetype)initWithScode:(NSString *)sCodeSelect KlineDataList:(WpQuoteServerDayKLineList *)KlineDataList TimeData:(NSArray*)TimeData{
    
    self = [super init];
    if(self){
        _sCode = sCodeSelect;
        self.KlineData = KlineDataList;
        self.timeData = TimeData;
    }
    return self;
}
#pragma mark viewDidload
- (void)viewDidLoad
{
    [super viewDidLoad];
    _type = MACD;
    [self addQuotaView];
    [self addScrollView];
    [self addCandleChartView];
    [self addTopBoxView];
    [self addButtonView];
    [self addTopView];

}
- (void)addTopView{
    
    [self addSubViews];
    [self addBottomViews];
    [self initCrossLine];
    [self addPriceView];
    [self addActivityView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataSource = [NSMutableArray array];
    [self loadData];
}
- (void)addSubViews
{
    [self addTechnicalView];
    [self addBottomView];
    [self addBottomBoxView];
    [self addGestureToCandleView];
}

#pragma mark 按键视图
-(void)addButtonView{
    
//    self.buyBtn = [[UIButton alloc]init];
//    self.buyBtn.backgroundColor = RoseColor;
//    [self.buyBtn.titleLabel setFont:[UIFont systemFontOfSize:20]];
//    [self.buyBtn setTitle:@"开仓" forState:UIControlStateNormal];
//    [self.buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.buyBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [self.buyBtn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    self.buyBtn.tag = 2000;
//    [self.view addSubview:self.buyBtn];
//    [self.buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        //make.top.equalTo(_bottomBoxView.mas_bottom).offset(5);
//        make.left.equalTo(self.view.mas_left).offset(5);
//        make.right.equalTo(self.view.mas_left).offset(201);
//        make.bottom.equalTo(self.view.mas_bottom);
//        make.height.equalTo(@(50));
//    }];
//    self.sellBtn = [[UIButton alloc]init];
//    self.sellBtn.backgroundColor = DropColor;
//    [self.sellBtn.titleLabel setFont:[UIFont systemFontOfSize:20]];
//    [self.sellBtn setTitle:@"平仓" forState:UIControlStateNormal];
//    [self.sellBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.sellBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [self.sellBtn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    self.sellBtn.tag = 2001;
//    [self.view addSubview:self.sellBtn];
//    [self.sellBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        //make.top.equalTo(_bottomBoxView.mas_bottom).offset(5);
//        make.left.equalTo(self.buyBtn.mas_right).offset(6);
//        make.right.equalTo(self.view.mas_right).offset(-6);
//        make.bottom.equalTo(self.view.mas_bottom);
//        make.height.equalTo(@(50));
//    }];
    
    
    self.klineBtn = [[UIButton alloc]init];
    self.klineBtn.backgroundColor = RoseColor;
    [self.klineBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.klineBtn setTitle:@"K-Line" forState:UIControlStateNormal];
    [self.klineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.klineBtn setTitleColor:RoseColor forState:UIControlStateHighlighted];
    self.klineBtn.tag = 2002;
    [self.klineBtn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.klineBtn];
    [self.klineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_quotaView.mas_bottom).offset(2);
        make.left.equalTo(self.view.mas_left).offset(5);
        make.width.equalTo(@(60));
        //make.right.equalTo(self.view.mas_right).offset(-6);
        //make.bottom.equalTo(_topBoxView.mas_top);
        make.bottom.equalTo(_topBoxView.mas_top).offset(-2);
    }];
    self.TlineBtn = [[UIButton alloc]init];
    self.TlineBtn.backgroundColor = DropColor;;
    [ self.TlineBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [ self.TlineBtn setTitle:@"T-Line" forState:UIControlStateNormal];
    [ self.TlineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ self.TlineBtn setTitleColor:RoseColor forState:UIControlStateHighlighted];
    self.TlineBtn.tag = 2003;
    [ self.TlineBtn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.TlineBtn];
    [ self.TlineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_quotaView.mas_bottom).offset(2);
        make.left.equalTo(self.klineBtn.mas_right);
        make.width.equalTo(@(60));
        //make.right.equalTo(self.view.mas_right).offset(-6);
        make.bottom.equalTo(_topBoxView.mas_top).offset(-2);
    }];
}


- (void)btnPressed:(id)sender{
    UIButton* btn = sender;
    switch (btn.tag){
//        case 2000:
//            NSLog(@"buy in");
//            self.buyVC = [[BuyVC alloc]init];
//            self.buyVC.Scode = [_sCode uppercaseString];
//            [self.navigationController pushViewController:self.buyVC animated:NO];
//            break;
//        case 2001:
//            NSLog(@"sell out");
//            break;
        case 2002:
            //self.timeLineView = nil;
            btn.enabled = NO;
            btn.backgroundColor = RoseColor;
            self.TlineBtn.enabled = YES;
            self.TlineBtn.backgroundColor = DropColor;
            [self.timeLineView removeFromSuperview];
            //[self addTopView];
            break;
        case 2003:
            btn.enabled = NO;
            btn.backgroundColor = RoseColor;
            self.klineBtn.backgroundColor = DropColor;
            self.klineBtn.enabled = YES;
            [self addTlineView];
            [self addTimeLineBox];
            break;
        default:
            NSLog(@"dddddd");
            break;
    }
}
#pragma mark 添加分时图
- (void)addTimeLineBox
{
    _timeLineBoxView = [UIView new];
    [self.timeLineView addSubview:_timeLineBoxView];
    _timeLineBoxView.userInteractionEnabled = NO;
    _timeLineBoxView.layer.borderWidth = 0.5*widthradio;
    _timeLineBoxView.layer.borderColor = [UIColor blackColor].CGColor;
    [_timeLineBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.height.equalTo(_timeLineView);
    }];
}
- (void)addTlineView{
    
    _timeLineView = [ZYWTimeLineView new];
    _timeLineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_timeLineView];
    [_timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        //make.left.right.equalTo(self.view);
        //make.height.equalTo(@(200));
        make.left.equalTo(self.view.mas_left).offset(3);
        make.right.equalTo(self.view.mas_right).offset(-5);
        make.top.equalTo(_candleChartView);
        make.bottom.equalTo(_bottomBoxView.mas_bottom);
    }];
    [_timeLineView layoutIfNeeded];
    
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
        _timeLineView.lineWidth = 0.1;
        _timeLineView.lineColor = [UIColor colorWithHexString:@"0033F0"];
        _timeLineView.fillColor = [UIColor colorWithHexString:@"CCFFFF"];
        _timeLineView.timesCount = 243;
        _timeLineView.dataArray = timeArray.mutableCopy;
        [_timeLineView stockFill];
    }
    else{
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"No data"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}
#pragma mark 添加视图 view
- (void)addActivityView
{
    _activityView = [UIActivityIndicatorView new];
    [self.view addSubview:_activityView];
    _activityView.hidesWhenStopped = YES;
    _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(5));
        make.centerY.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
}

- (void)addQuotaView
{
    _quotaView = [ZYWCrossPriceView new];
    _quotaView.backgroundColor = DropColor;
    [self.view addSubview:_quotaView];
    [_quotaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(20));
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(50));
    }];
}

- (void)addScrollView
{
    _scrollView = [UIScrollView new];
    [self.view addSubview:_scrollView];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_quotaView.mas_bottom).offset(30);
        make.left.equalTo(@(5));
        make.width.mas_equalTo( DEVICE_HEIGHT - 60 - 5);
        make.height.mas_equalTo(DEVICE_WIDTH - 50 - 20);
    }];
}

- (void)addCandleChartView
{
    _candleChartView = [ZYWCandleChartView new];
    [_scrollView addSubview:_candleChartView];
    _candleChartView.delegate = self;
    _currentZoom = -0.1f;
    [_candleChartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView);
        make.right.equalTo(_scrollView);
        make.height.equalTo(@((DEVICE_WIDTH - 120)*CandleChartScale));
        make.top.equalTo(_scrollView);
    }];
    _candleChartView.candleSpace = 2;
    _candleChartView.displayCount = 15;
    _displayCount = 25;
    _candleChartView.lineWidth = 1*widthradio;
}

- (void)addTopBoxView
{
    _topBoxView = [UIView new];
    [self.view addSubview:_topBoxView];
    _topBoxView.userInteractionEnabled = NO;
    _topBoxView.layer.borderWidth = 1*widthradio;
    _topBoxView.layer.borderColor = [UIColor blackColor].CGColor;
    [_topBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_scrollView.mas_top).offset(1*heightradio);
        make.left.equalTo(_scrollView.mas_left).offset(-1*widthradio);
        make.right.equalTo(_scrollView.mas_right).offset(1*widthradio);
        make.height.equalTo(@((DEVICE_WIDTH - 120)*CandleChartScale));
    }];
}

- (void)addTechnicalView
{
    _technicalView = [ZYWTecnnicalView new];
    [self.view addSubview:_technicalView];
    _technicalView.delagate = self;
    
    [_technicalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topBoxView.mas_bottom);
        make.left.right.equalTo(_scrollView);
        make.height.equalTo(@((DEVICE_WIDTH-70)*TechnicalViewScale));
    }];
    
    [_technicalView.macdButton setTitle:@"MACD" forState:UIControlStateNormal];
    [_technicalView.wrButton setTitle:@"WR" forState:UIControlStateNormal];
    [_technicalView.kdjButton setTitle:@"KDJ" forState:UIControlStateNormal];
}

- (void)addBottomView
{
    _bottomView = [UIView new];
    [_scrollView addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_technicalView.mas_bottom).offset(widthradio);
        make.left.right.equalTo(_candleChartView);
        make.height.equalTo(@((DEVICE_WIDTH-70)*BottomViewScale));
    }];
    [_bottomView layoutIfNeeded];
}

- (void)addBottomBoxView
{
    _bottomBoxView = [UIView new];
    [self.view addSubview:_bottomBoxView];
    _bottomBoxView.userInteractionEnabled = NO;
    _bottomBoxView.layer.borderWidth = 1*widthradio;
    _bottomBoxView.layer.borderColor = [UIColor blackColor].CGColor;
    [_bottomBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bottomView.mas_top).offset(-1*heightradio);
        make.left.equalTo(_scrollView.mas_left).offset(-1*widthradio);
        make.right.equalTo(_scrollView.mas_right).offset(1*widthradio);
        make.height.equalTo(@((DEVICE_WIDTH - 70)*BottomViewScale));
    }];
}

- (void)addPriceView
{
    _topPriceView = [ZYWPriceView new];
    [self.view addSubview:_topPriceView];
    
    [_topPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_topBoxView);
        make.left.equalTo(_topBoxView.mas_right);
    }];
    
    _bottomPriceView = [ZYWPriceView new];
    [self.view addSubview:_bottomPriceView];
    
    [_bottomPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_bottomBoxView);
        make.left.equalTo(_bottomBoxView.mas_right);
    }];
}

#pragma mark 添加手势

- (void)addGestureToCandleView
{
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [self.candleChartView addGestureRecognizer:_longPressGesture];

    _pinchPressGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchesView:)];
    [self.scrollView addGestureRecognizer:_pinchPressGesture];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    _tapGesture.numberOfTapsRequired = 2;
    [self.candleChartView addGestureRecognizer:_tapGesture];
}

#pragma mark 指标视图

- (void)addBottomViews
{
    _macdView = [ZYWMacdView new];
    [_bottomView addSubview:_macdView];
    _macdView.lineWidth = 1*widthradio;
    [_macdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_bottomView);
        make.left.right.equalTo(_bottomView);
    }];
    _kdjLineView = [ZYWKdjLineView new];
    [_bottomView addSubview:_kdjLineView];
    _kdjLineView.lineWidth = 1*widthradio;
    [_kdjLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_bottomView);
        make.left.right.equalTo(_bottomView);
    }];
    _kdjLineView.hidden = YES;
    _wrLineView = [ZYWWrLineView new];
    [_bottomView addSubview:_wrLineView];
    _wrLineView.lineWidth = 1*widthradio;
    [_wrLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_bottomView);
        make.left.right.equalTo(_bottomView);
    }];
    _wrLineView.hidden = YES;
}

#pragma mark 十字线

- (void)initCrossLine
{
    self.verticalView = [UIView new];
    self.verticalView.clipsToBounds = YES;
    [self.scrollView addSubview:self.verticalView];
    self.verticalView.backgroundColor = [UIColor colorWithHexString:@"666666"];
    [self.verticalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBoxView);
        make.width.equalTo(@(_candleChartView.lineWidth));
        make.bottom.equalTo(_macdView);
        make.left.equalTo(@(0));
    }];
    self.leavView = [UIView new];
    self.leavView.clipsToBounds = YES;
    [self.scrollView addSubview:self.leavView];
    self.leavView.backgroundColor = [UIColor colorWithHexString:@"666666"];;
    [self.leavView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(0));
        make.left.equalTo(self.view);
        make.right.equalTo(self.candleChartView);
        make.height.equalTo(@(_candleChartView.lineWidth));
    }];
    self.leavView.hidden = YES;
    self.verticalView.hidden = YES;
}

#pragma mark 指标切换代理

- (void)didSelectButton:(UIButton *)button index:(NSInteger)index
{
    if (index == 1)
    {
        _type = MACD;
    }
    
    else if (index == 2)
    {
        _type = WR;
    }
    
    else
    {
        _type = KDJ;
    }
    
    [self showIndexLineView:self.candleChartView.leftPostion startIndex:self.candleChartView.currentStartIndex count:self.candleChartView.displayCount];
}

#pragma mark 长按手势

- (void)longGesture:(UILongPressGestureRecognizer*)longPress
{
    static CGFloat oldPositionX = 0;
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state)
    {
        CGPoint location = [longPress locationInView:self.candleChartView];
        if(ABS(oldPositionX - location.x) < (self.candleChartView.candleWidth + self.candleChartView.candleSpace)/2)
        {
            return;
        }
        self.scrollView.scrollEnabled = NO;
        oldPositionX = location.x;
        CGPoint point = [self.candleChartView getLongPressModelPostionWithXPostion:location.x];
        CGFloat xPositoin = point.x + (self.candleChartView.candleWidth)/2.f - self.candleChartView.candleSpace/2.f ;
        CGFloat yPositoin = point.y +_candleChartView.topMargin;
        [self.verticalView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(xPositoin));
        }];
        [_quotaView layoutIfNeeded];
        [self.leavView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(yPositoin);
        }];
        self.verticalView.hidden = NO;
        self.leavView.hidden = NO;
    }
    if(longPress.state == UIGestureRecognizerStateEnded)
    {
        if(self.verticalView)
        {
            self.verticalView.hidden = YES;
        }
        
        if(self.leavView)
        {
            self.leavView.hidden = YES;
        }
        oldPositionX = 0;
        self.scrollView.scrollEnabled = YES;
    }
}

#pragma mark 缩放手势

- (void)pinchesView:(UIPinchGestureRecognizer *)pinchTap
{
    if (pinchTap.state == UIGestureRecognizerStateEnded)
    {
        _currentZoom = pinchTap.scale;
        self.scrollView.scrollEnabled = YES;
    }
    
    else if (pinchTap.state == UIGestureRecognizerStateBegan && _currentZoom != 0.0f)
    {
        self.scrollView.scrollEnabled = NO;
        pinchTap.scale = _currentZoom;
        
        ZYWCandlePostionModel *model = self.candleChartView.currentPostionArray.lastObject;
        _zoomRightIndex = model.localIndex + 1;
    }
    
    else if (pinchTap.state == UIGestureRecognizerStateChanged)
    {
        CGFloat tmpZoom = 0.f;
        if (isnan(_currentZoom))
        {
            return;
        }
        tmpZoom = (pinchTap.scale)/ _currentZoom;
        _currentZoom = pinchTap.scale;
        NSInteger showNum = round(_displayCount / tmpZoom);
        
        if (showNum == _displayCount)
        {
            return;
        }
        
        if (showNum >= _displayCount && _displayCount == MaxCount) return;
        if (showNum <= _displayCount && _displayCount == MinCount) return;
        
        _displayCount = showNum;
        _displayCount = _displayCount < MinCount ? MinCount : _displayCount;
        _displayCount = _displayCount > MaxCount ? MaxCount : _displayCount;
        
        _candleChartView.displayCount = _displayCount;
        [_candleChartView calcuteCandleWidth];
        [_candleChartView updateWidthWithNoOffset];
        [_candleChartView drawKLine];
        CGFloat offsetX = fabs(_zoomRightIndex* (self.candleChartView.candleSpace + self.candleChartView.candleWidth) - self.scrollView.width + self.candleChartView.leftMargin) ;
        if (offsetX <= self.scrollView.frame.size.width)
        {
            offsetX = 0;
        }
        
        if (offsetX > self.scrollView.contentSize.width - self.scrollView.frame.size.width)
        {
            offsetX = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
        }
        
        self.scrollView.contentOffset = CGPointMake(offsetX, 0);
    }
}
#pragma mark 竖屏手势

- (void)tapGesture:(UITapGestureRecognizer*)tapGesture
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(willChangeScreenMode:)])
    {
        [self.delegate willChangeScreenMode:self];
    }
}

#pragma mark 数据读取

- (void)loadData {
//    NSString *fileName = @"N225.xml";
//    NSArray *fileComponents = [fileName componentsSeparatedByString:@"."];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0]
//                                                         ofType:[fileComponents objectAtIndex:1]];
//    NSURL *url = [NSURL fileURLWithPath:filePath];
//    NSXMLParser *parser = [[[NSXMLParser alloc] init] initWithContentsOfURL:url];
//    parser.delegate = self;
//    [parser parse];
//
    NSEnumerator *enumerator = [ self.KlineData objectEnumerator];
    id obj = nil;
    while (obj = [enumerator nextObject]){
        WpQuoteServerDayKLineCodeInfo* kline = [[WpQuoteServerDayKLineCodeInfo alloc]init];
        kline = obj;
        if([_sCode isEqualToString: kline.sCode])
        {
            ZYWCandleModel *data = [[ZYWCandleModel alloc] init];
            data.open = [kline.sOpenPrice floatValue];
            data.high = [kline.sHighPrice floatValue];
            data.low = [kline.sLowPrice floatValue];
            data.close = [kline.sLastPrice floatValue];
            data.date = kline.sDate;
            self.model = data;
            if (self.dataSource == nil)
            {
                self.dataSource = [[NSMutableArray alloc] init];
            }
            [self.dataSource addObject:self.model];
        }
    }
    
    NSMutableArray * newMarray = [NSMutableArray array];
    NSEnumerator * enumerator1 = [self.dataSource reverseObjectEnumerator];//倒序排列
    id object;
    while (object = [enumerator1 nextObject])
    {
        [newMarray addObject:object];
    }
    [self reloadData:newMarray reload:NO];
}
- (void)reloadData:(NSMutableArray*)array reload:(BOOL)reload
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _macdView.dataArray = computeMACDData(array).mutableCopy;
        _kdjLineView.dataArray = computeKDJData(array).mutableCopy;
        _wrLineView.dataArray = computeWRData(array,10).mutableCopy;
        
        for (NSInteger i = 0;i<array.count;i++)
        {
            ZYWCandleModel *model = array[i];
            if (i % 20 == 0)
            {
                model.isDrawDate = YES;
            }
            else
            {
                model.isDrawDate = NO;
            }
        }
        self.candleChartView.dataArray = array;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.candleChartView stockFill];
        });
    });
}
//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
//{
//    if ([elementName isEqualToString:@"item"])
//    {
//        ZYWCandleModel *data = [[ZYWCandleModel alloc] init];
//        data.open = [[attributeDict objectForKey:@"open"] floatValue];
//        data.high = [[attributeDict objectForKey:@"high"] floatValue];
//        data.low =  [[attributeDict objectForKey:@"low"] floatValue];
//        data.close = [[attributeDict objectForKey:@"close"] floatValue];
//        data.date = [attributeDict objectForKey:@"date"];
//        self.model = data;
//    }
//}

//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
//    if ([elementName isEqualToString:@"item"])
//    {
//        if (self.dataSource == nil)
//        {
//            self.dataSource = [[NSMutableArray alloc] init];
//        }
//        [self.dataSource addObject:self.model];
//    }
//}
//
//- (void)parserDidEndDocument:(NSXMLParser *)parser
//{
//    NSMutableArray * newMarray = [NSMutableArray array];
//    NSEnumerator * enumerator = [self.dataSource reverseObjectEnumerator];
//
//    id object;
//    while (object = [enumerator nextObject])
//    {
//        [newMarray addObject:object];
//    }
//    [self reloadData:newMarray reload:NO];
//}



#pragma mark candleLineDelegeta

- (void)displayLastModel:(ZYWCandleModel *)kLineModel
{
    _quotaView.model = kLineModel;
}

- (void)longPressCandleViewWithIndex:(NSInteger)kLineModeIndex kLineModel:(ZYWCandleModel *)kLineModel
{
    _quotaView.model = kLineModel;
}

- (void)displayScreenleftPostion:(CGFloat)leftPostion startIndex:(NSInteger)index count:(NSInteger)count
{
    [self showIndexLineView:leftPostion startIndex:index count:count];
}

- (void)showIndexLineView:(CGFloat)leftPostion startIndex:(NSInteger)index count:(NSInteger)count
{
    _topPriceView.maxPriceLabel.text = [NSString stringWithFormat:@"%.2f",self.candleChartView.maxY];
    _topPriceView.middlePriceLabel.text = [NSString stringWithFormat:@"%.2f",(self.candleChartView.maxY - self.candleChartView.minY)/2 + self.candleChartView.minY];
    _topPriceView.minPriceLabel.text = [NSString stringWithFormat:@"%.2f",self.candleChartView.minY];
    
    if (_type == MACD)
    {
        [_kdjLineView setHidden:YES];
        [_wrLineView setHidden:YES];
        [_macdView setHidden:NO];
        _macdView.candleSpace = _candleChartView.candleSpace;
        _macdView.candleWidth = _candleChartView.candleWidth;
        _macdView.leftPostion = leftPostion;
        _macdView.startIndex = index;
        _macdView.displayCount = count;
        [_macdView stockFill];
        
        _bottomPriceView.maxPriceLabel.text = [NSString stringWithFormat:@"%.2f",self.macdView.maxY];
        _bottomPriceView.middlePriceLabel.text = [NSString stringWithFormat:@"%.2f",(self.macdView.maxY - self.macdView.minY)/2 + self.macdView.minY];
        _bottomPriceView.minPriceLabel.text = [NSString stringWithFormat:@"%.2f",self.macdView.minY];
    }
    
    else  if (_type == WR)
    {
        [_kdjLineView setHidden:YES];
        [_macdView setHidden:YES];
        [_wrLineView setHidden:NO];
        _wrLineView.candleSpace = _candleChartView.candleSpace;
        _wrLineView.candleWidth = _candleChartView.candleWidth;
        _wrLineView.leftPostion = leftPostion;
        _wrLineView.startIndex = index;
        _wrLineView.displayCount = count;
        [_wrLineView stockFill];
        
        _bottomPriceView.maxPriceLabel.text = [NSString stringWithFormat:@"%.2f",self.wrLineView.maxY];
        _bottomPriceView.middlePriceLabel.text = [NSString stringWithFormat:@"%.2f",(self.wrLineView.maxY - self.wrLineView.minY)/2 + self.wrLineView.minY];
        _bottomPriceView.minPriceLabel.text = [NSString stringWithFormat:@"%.2f",self.wrLineView.minY];
    }
    
    else if(_type == KDJ)
    {
        [_kdjLineView setHidden:NO];
        [_macdView setHidden:YES];
        [_wrLineView setHidden:YES];
        _kdjLineView.candleSpace = _candleChartView.candleSpace;
        _kdjLineView.candleWidth = _candleChartView.candleWidth;
        _kdjLineView.leftPostion = leftPostion;
        _kdjLineView.startIndex = index;
        _kdjLineView.displayCount = count;
        [_kdjLineView stockFill];
        
        _bottomPriceView.maxPriceLabel.text = [NSString stringWithFormat:@"%.2f",self.kdjLineView.maxY];
        _bottomPriceView.middlePriceLabel.text = [NSString stringWithFormat:@"%.2f",(self.kdjLineView.maxY - self.kdjLineView.minY)/2 + self.kdjLineView.minY];
        _bottomPriceView.minPriceLabel.text = [NSString stringWithFormat:@"%.2f",self.kdjLineView.minY];
    }
}

- (void)displayMoreData
{
    NSLog(@"正在加载更多....");
    [_activityView startAnimating];
    __weak typeof(self) this = self;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0* NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [this loadMoreData];
    });
}

- (void)loadMoreData
{
    NSMutableArray *tempArray = _candleChartView.dataArray.mutableCopy;
    for (NSInteger i = 0; i < _candleChartView.dataArray.count; i++) {
        ZYWCandleModel *model = _candleChartView.dataArray[i];
        [tempArray addObject:model];
    }
    [self reloadData:tempArray reload:YES];
    
    [_activityView stopAnimating];
}

#pragma mark 屏幕相关

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.orientation;
}

#pragma mark Memory

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
