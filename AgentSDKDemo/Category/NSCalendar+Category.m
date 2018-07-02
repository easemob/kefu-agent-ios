//
//  NSCalendar+Category.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/6/27.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "NSCalendar+Category.h"

@implementation NSCalendar (Category)
- (NSArray *)getFirstAndLastDayOfThisWeek
{
    NSDateComponents *dateComponents = [self components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger weekday = [dateComponents weekday];
    NSInteger firstDiff,lastDiff;
    if (weekday == 1) {
        firstDiff = -6;
        lastDiff = 0;
    }else {
        firstDiff =  - weekday + 2;
        lastDiff = 8 - weekday;
    }
    NSInteger day = [dateComponents day];
    NSDateComponents *firstComponents = [self components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [firstComponents setDay:day+firstDiff];
    NSDate *firstDay = [self dateFromComponents:firstComponents];
    
    NSDateComponents *lastComponents = [self components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [lastComponents setDay:day+lastDiff];
    NSDate *lastDay = [self dateFromComponents:lastComponents];
    return [NSArray arrayWithObjects:firstDay,lastDay, nil];
}

- (NSArray *)getFirstAndLastDayOfLastWeek {
    NSDateComponents *dateComponents = [self components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger weekday = [dateComponents weekday];
    NSInteger firstDiff,lastDiff;
    if (weekday == 1) {
        firstDiff = -6;
        lastDiff = 0;
    }else {
        firstDiff =  - weekday + 2;
        lastDiff = 8 - weekday;
    }
    [dateComponents setDay:[dateComponents day] - 7];
    NSInteger day = [dateComponents day];
    NSDateComponents *firstComponents = [self components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [firstComponents setDay:day+firstDiff];
    NSDate *firstDay = [self dateFromComponents:firstComponents];
    
    NSDateComponents *lastComponents = [self components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [lastComponents setDay:day+lastDiff];
    NSDate *lastDay = [self dateFromComponents:lastComponents];
    return [NSArray arrayWithObjects:firstDay,lastDay, nil];
}

- (NSArray *)getFirstAndLastDayOfThisMonth
{
    NSDate *firstDay;
    [self rangeOfUnit:NSCalendarUnitMonth startDate:&firstDay interval:nil forDate:[NSDate date]];
    NSDateComponents *lastDateComponents = [self components:NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay fromDate:firstDay];
    NSUInteger dayNumberOfMonth = [self rangeOfUnit:NSCalendarUnitDay
                                             inUnit:NSCalendarUnitMonth
                                            forDate:[NSDate date]].length;
    NSInteger day = [lastDateComponents day];
    [lastDateComponents setDay:day + dayNumberOfMonth - 1];
    NSDate *lastDay = [self dateFromComponents:lastDateComponents];
    return [NSArray arrayWithObjects:firstDay,lastDay, nil];
}

- (NSArray *)getFirstAndLastDayOfLastMonth {
    NSDateComponents *cmp = [self components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[[NSDate alloc] init]];
    [cmp setMonth:[cmp month] - 1];
    NSDate *firstDay = [self dateFromComponents:cmp];
    NSDateComponents *lastDateComponents = [self components:NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay fromDate:firstDay];
    NSUInteger dayNumberOfMonth = [self rangeOfUnit:NSCalendarUnitDay
                                             inUnit:NSCalendarUnitMonth
                                            forDate:[NSDate date]].length;
    NSInteger day = [lastDateComponents day];
    [lastDateComponents setDay:day + dayNumberOfMonth - 1];
    NSDate *lastDay = [self dateFromComponents:lastDateComponents];
    return [NSArray arrayWithObjects:firstDay,lastDay, nil];
}

@end
