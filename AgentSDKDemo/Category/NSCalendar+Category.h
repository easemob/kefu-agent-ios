//
//  NSCalendar+Category.h
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/6/27.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (Category)
- (NSArray *)getFirstAndLastDayOfThisWeek;
- (NSArray *)getFirstAndLastDayOfLastWeek;
- (NSArray *)getFirstAndLastDayOfThisMonth;
- (NSArray *)getFirstAndLastDayOfLastMonth;
@end
