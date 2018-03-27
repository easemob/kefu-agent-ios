//
//  NSDate+Formatter.m
//  EMCSApp
//
//  Created by dhc on 15/4/11.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "NSDate+Formatter.h"

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@implementation NSDate (Formatter)

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}


/*格式化日期描述*/
- (NSString *)formattedDateDescription
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    
    NSInteger timeInterval = -[self timeIntervalSinceNow];
    if (timeInterval < D_MINUTE) {
        return @"1分钟内";
    } else if (timeInterval < D_HOUR) {//1小时内
        return [NSString stringWithFormat:@"%.f分钟前", timeInterval / 60.0];
    } else if (timeInterval < 21600) {//6小时内
        return [NSString stringWithFormat:@"%.f小时前", timeInterval / 3600.0];
    } else if ([theDay isEqualToString:currentDay]) {//当天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"今天 %@", [dateFormatter stringFromDate:self]];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == D_DAY) {//昨天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:self]];
    } else {//以前
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        return [dateFormatter stringFromDate:self];
    }
}

/*精确到分钟的日期描述*/
- (NSString *)minuteDescription
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    if ([theDay isEqualToString:currentDay]) {//当天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [dateFormatter stringFromDate:self];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) {//昨天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:self]];
    } else {//以前
        [dateFormatter setDateFormat:@"yyyy-MM-dd ah:mm"];
        return [dateFormatter stringFromDate:self];
    }
}

- (NSString *)monthDescription {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd HH:mm";
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dateDescription {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    return [dateFormatter stringFromDate:self];
}

@end
