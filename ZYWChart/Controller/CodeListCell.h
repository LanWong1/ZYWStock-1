//
//  CodeListCell.h
//  ZYWChart
//
//  Created by IanWong on 2018/11/12.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CodeListCell : UITableViewCell

@property (strong,nonatomic) UILabel *lastPriceLabel;
@property (strong,nonatomic) UILabel *priceChangePercentageLabel;
@property (strong,nonatomic) UILabel *openInsertLabel;


+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
