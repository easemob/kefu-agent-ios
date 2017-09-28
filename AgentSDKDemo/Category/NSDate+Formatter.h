//
//  NSDate+Formatter.h
//  EMCSApp
//
//  Created by dhc on 15/4/11.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatter)

/*格式化日期描述*/
- (NSString *)formattedDateDescription;

/*精确到分钟的日期描述*/
- (NSString *)minuteDescription;

@end
