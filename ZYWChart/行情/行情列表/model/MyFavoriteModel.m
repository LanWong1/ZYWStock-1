//
//  MyFavoriteModel.m
//  ZYWChart
//
//  Created by zdqh on 2018/11/14.
//  Copyright © 2018 zyw113. All rights reserved.
//

#import "MyFavoriteModel.h"

@implementation MyFavoriteModel


- (instancetype)initWithCode:(NSString *)code index:(NSInteger)index{
    
    self = [super init];
    
    if (self) {
        self.code = code;
        self.index = index;
    }
    return self;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        //self.index = 0;
        self.code = @"";
    }
    return self;
}
@end
