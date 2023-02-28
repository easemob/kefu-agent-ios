//
//  HCustomerLocalModel.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2018/6/4.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCustomerLocalModel : NSObject

- (instancetype)initWithArray:(NSArray *)ary;

@property (nonatomic, copy) NSString *ip;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *userAgent;

@end
