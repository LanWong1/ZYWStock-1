//
//  MyFavoriteModel.h
//  ZYWChart
//
//  Created by zdqh on 2018/11/14.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyFavoriteModel : NSObject
@property(nonatomic, strong) NSString* code;
@property(nonatomic, assign) NSInteger index;

- (instancetype)initWithCode:(NSString*)code index:(NSInteger)index;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
