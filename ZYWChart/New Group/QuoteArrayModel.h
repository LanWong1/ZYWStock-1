//
//  QuoteArrayModel.h
//  ZYWChart
//
//  Created by zdqh on 2018/11/1.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuoteModel.h"
NS_ASSUME_NONNULL_BEGIN



@protocol QuoteArrayModelDelegate <NSObject>

@optional
- (void)reloadData:(NSMutableArray*)array;

- (void)quoteViewRefresh:(NSMutableArray*)array;
@end


@interface QuoteArrayModel : NSObject

@property (nonatomic,strong)  NSMutableArray<__kindof QuoteModel*> *quoteModelArray;

@property(weak,nonatomic) id<QuoteArrayModelDelegate> delegate;
+(QuoteArrayModel*)shareInstance;
@end

NS_ASSUME_NONNULL_END
