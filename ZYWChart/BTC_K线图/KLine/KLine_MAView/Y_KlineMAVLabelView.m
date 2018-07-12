//
//  Y_KlineMAVLabelView.m
//  ZYWChart
//
//  Created by zdqh on 2018/7/10.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "Y_KlineMAVLabelView.h"
#import "Masonry.h"
#import "UIColor+Y_StockChart.h"
#import "Y_KLineModel.h"
@interface Y_KlineMAVLabelView ()

@property (strong, nonatomic) UILabel *MA7Label;

@property (strong, nonatomic) UILabel *MA30Label;

@property (strong, nonatomic) UILabel *dateDescLabel;

@property (strong, nonatomic) UILabel *openDescLabel;

@property (strong, nonatomic) UILabel *closeDescLabel;

@property (strong, nonatomic) UILabel *highDescLabel;

@property (strong, nonatomic) UILabel *lowDescLabel;

@property (strong, nonatomic) UILabel *openLabel;

@property (strong, nonatomic) UILabel *closeLabel;

@property (strong, nonatomic) UILabel *highLabel;

@property (strong, nonatomic) UILabel *lowLabel;

@end

@implementation Y_KlineMAVLabelView



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        _MA7Label = [self private_createLabel];
        _MA30Label = [self private_createLabel];
        _dateDescLabel = [self private_createLabel];
        _openDescLabel = [self private_createLabel];
        _openDescLabel.text = @" 开:";
        _closeDescLabel = [self private_createLabel];
        _closeDescLabel.text = @" 收:";
        _highDescLabel = [self private_createLabel];
        _highDescLabel.text = @" 高:";
        _lowDescLabel = [self private_createLabel];
        _lowDescLabel.text = @" 低:";
        _openLabel = [self private_createLabel];
        _closeLabel = [self private_createLabel];
        _highLabel = [self private_createLabel];
        _lowLabel = [self private_createLabel];
        _MA7Label.textColor = [UIColor ma7Color];
        _MA30Label.textColor = [UIColor ma30Color];
        _openLabel.textColor = [UIColor whiteColor];
        _highLabel.textColor = [UIColor whiteColor];
        _lowLabel.textColor = [UIColor whiteColor];
        _closeLabel.textColor = [UIColor whiteColor];
   
        NSNumber *labelWidth = [NSNumber numberWithInt:55];
       // NSNumber *labelHeight = [NSNumber numberWithInt:6];
        
        [_dateDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            //make.bottom.equalTo(self.mas_bottom);
            make.width.equalTo(@100);
            
        }];
        
        [_openDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            //make.top.equalTo(self.mas_top);
            make.left.equalTo(self.mas_left);
            make.top.equalTo(_dateDescLabel.mas_bottom);
            
            //make.bottom.equalTo(self.mas_bottom);
        }];
        
        [_openLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_openDescLabel.mas_right);
            make.bottom.equalTo(self.openDescLabel.mas_bottom);
            make.width.equalTo(labelWidth);
            
        }];
        
        [_highDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(_openDescLabel.mas_bottom);
            //make.height.equalTo(labelHeight);
            //make.bottom.equalTo(self.mas_bottom);
        }];
        
        [_highLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_highDescLabel.mas_right);
            //make.top.equalTo(self.mas_top);
            make.bottom.equalTo(_highDescLabel.mas_bottom);
            //make.height.equalTo(labelHeight);
            make.width.equalTo(labelWidth);
            
        }];
        
        [_lowDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(_highDescLabel.mas_bottom);
           // make.height.equalTo(labelHeight);
            //make.bottom.equalTo(self.mas_bottom);
        }];
        
        [_lowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_lowDescLabel.mas_right);
            make.bottom.equalTo(_lowDescLabel.mas_bottom);
           // make.height.equalTo(labelHeight);
            // make.bottom.equalTo(self.mas_bottom);
            make.width.equalTo(labelWidth);
            
        }];
        
        [_closeDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(_lowDescLabel.mas_bottom);
             //make.height.equalTo(labelHeight);
            //make.bottom.equalTo(self.mas_bottom);
        }];
        
        [_closeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_closeDescLabel.mas_right);
            //make.top.equalTo(self.mas_top);
            make.bottom.equalTo(_closeDescLabel.mas_bottom);
            //make.height.equalTo(labelHeight);
            make.width.equalTo(labelWidth);
            
        }];
        
        [_MA7Label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
           
            make.top.equalTo(_closeDescLabel.mas_bottom);
            //make.height.equalTo(labelHeight);
            
        }];
        //
        [_MA30Label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(_MA7Label.mas_bottom);
            //make.height.equalTo(labelHeight);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
    }
    return self;
}



-(void)maProfileWithModel:(Y_KLineModel *)model
{
//    NSLog(@"model.Date = %@",model.Date);
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.Date.doubleValue/1000];
//    NSLog(@"data = %@",date);
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
//    NSString *dateStr = [formatter stringFromDate:date];
//    _dateDescLabel.text = [@" " stringByAppendingString: dateStr];
    
    
    _dateDescLabel.text = [@" " stringByAppendingString: model.Date];
    _openLabel.text = [NSString stringWithFormat:@"%.2f",model.Open.floatValue];
    _highLabel.text = [NSString stringWithFormat:@"%.2f",model.High.floatValue];
    _lowLabel.text = [NSString stringWithFormat:@"%.2f",model.Low.floatValue];
    _closeLabel.text = [NSString stringWithFormat:@"%.2f",model.Close.floatValue];
    _MA7Label.text = [NSString stringWithFormat:@" MA7：%.2f ",model.MA7.floatValue];
    _MA30Label.text = [NSString stringWithFormat:@" MA30：%.2f",model.MA30.floatValue];
}
- (UILabel *)private_createLabel
{
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor assistTextColor];
    [self addSubview:label];
    return label;
}
@end
