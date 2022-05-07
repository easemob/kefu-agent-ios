//
//  StatisticsModel.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/24.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatisticsModel : NSObject

@property (nonatomic) NSInteger newSessionCount;
@property (nonatomic) NSInteger curSessionCount;
@property (nonatomic) NSInteger curOnlineCount;
@property (nonatomic) NSInteger todayMessageCount;

@property (nonatomic, strong) NSArray *messsageCount;
@property (nonatomic, strong) NSArray *sessionCount;

@end
