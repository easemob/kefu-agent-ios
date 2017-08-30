//
//  HDHistoryRequestBody.h
//  AgentSDK
//
//  Created by afanda on 8/16/17.
//  Copyright © 2017 环信. All rights reserved.
//

/**
 请求历史会话请求体
*/

#import <Foundation/Foundation.h>

@interface HDHistoryRequestBody : NSObject

@property(nonatomic,copy) NSDate *beginDate; //开始日期
@property(nonatomic,copy) NSDate *endDate;  //结束日期


@end
