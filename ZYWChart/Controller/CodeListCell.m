//
//  CodeListCell.m
//  ZYWChart
//
//  Created by IanWong on 2018/11/12.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "CodeListCell.h"

@implementation CodeListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
 {
         // NSLog(@"cellForRowAtIndexPath");
        static NSString *identifier = @"status";
         // 1.缓存中取
         CodeListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
         // 2.创建
         if (cell == nil) {
                 cell = [[CodeListCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
             }
        return cell;
     }


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    NSLog(@"init cell=======");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){
        [self.contentView addSubview:self.priceChangePercentageLabel];
        
        [self.contentView addSubview:self.lastPriceLabel];
        
        [self.contentView addSubview:self.openInsertLabel];
        
    }
    return self;
}




-(UILabel*)priceChangePercentageLabel{
    if(!_priceChangePercentageLabel){
        _priceChangePercentageLabel = [[UILabel alloc]initWithFrame:CGRectMake(230, 0, 60, self.height)];
        _priceChangePercentageLabel.font = [UIFont systemFontOfSize:16];
        _priceChangePercentageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _priceChangePercentageLabel;
}

-(UILabel*)lastPriceLabel{
    if(!_lastPriceLabel){
        _lastPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 0, 60, self.height)];
        //lable.adjustsFontSizeToFitWidth = YES;
        _lastPriceLabel.textAlignment = NSTextAlignmentCenter;
        _lastPriceLabel.font = [UIFont systemFontOfSize:16];
    }
    return _lastPriceLabel;
}

-(UILabel *)openInsertLabel{
    if(!_openInsertLabel){
        _openInsertLabel = [[UILabel alloc]initWithFrame:CGRectMake(330, 0, 80, self.height)];
        //lable.adjustsFontSizeToFitWidth = YES;
        _openInsertLabel.textAlignment = NSTextAlignmentCenter;
        _openInsertLabel.font = [UIFont systemFontOfSize:16];
    }
    return _openInsertLabel;
}

@end
