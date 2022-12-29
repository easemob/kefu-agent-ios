//
//  HDMonitorModels.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2018/3/9.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

// 客服状态数量分布model
@interface HDAgentStatusDistCountModel : NSObject
- (instancetype)initWithDictionary:(NSDictionary *)aDict;
@property (nonatomic, assign, readonly) NSInteger busyCount;    // 忙碌状态数
@property (nonatomic, assign, readonly) NSInteger hiddenCount;  // 隐身状态数
@property (nonatomic, assign, readonly) NSInteger leaveCount;   // 离开状态数
@property (nonatomic, assign, readonly) NSInteger offlineCount; // 离线状态数
@property (nonatomic, assign, readonly) NSInteger onlineCount;  // 在线状态数
@end

// 客服负载数量model
@interface HDAgentLoadCountModel : NSObject
- (instancetype)initWithDictionary:(NSDictionary *)aDict;
@property (nonatomic, assign, readonly) NSInteger processingCount;
@property (nonatomic, assign, readonly) NSInteger totalCount;
@end

// 待接入数量model
@interface HDVisitorWaitCountModel : NSObject
- (instancetype)initWithDictionary:(NSDictionary *)aDict;
@property (nonatomic, strong, readonly) NSArray *timestampAry;  // 时间戳数组
@property (nonatomic, strong, readonly) NSArray *countAry;      // 时间戳数组对应
@property (nonatomic, assign, readonly) NSInteger maxCount;     // 时间戳内最大待接入数
@end

// 会话数model
@interface HDAgentSessionCountModel: NSObject
- (instancetype)initWithDictionary:(NSDictionary *)aDict;
@property (nonatomic, assign, readonly) NSInteger newSessionCount; // 新进行中会话数
@property (nonatomic, assign, readonly) NSInteger endSessionCount; // 结束会话数
@property (nonatomic, assign, readonly) NSInteger effectiveSessionCount; // 进行中有效会话数
@property (nonatomic, assign, readonly) NSInteger invalidSessionCount;   // 进行中无效会话数
@end

// 访客来源model
@interface HDVisterSourceModel: NSObject
- (instancetype)initWithDictionary:(NSDictionary *)aDict;
@property (nonatomic, assign, readonly) NSInteger appCount;       // App渠道
@property (nonatomic, assign, readonly) NSInteger phoneCount;
@property (nonatomic, assign, readonly) NSInteger restCount;
@property (nonatomic, assign, readonly) NSInteger slackCount;
@property (nonatomic, assign, readonly) NSInteger webCount;
@property (nonatomic, assign, readonly) NSInteger weiBoCount;
@property (nonatomic, assign, readonly) NSInteger weiXinCount;
@end

// 服务质量model
@interface HDAgentQualityModel: NSObject
- (instancetype)initWithDictionary:(NSDictionary *)aDict;
@property (nonatomic, assign, readonly) NSInteger averageTime;  // 平均时长
@property (nonatomic, assign, readonly) NSInteger firstTime;    // 首响时长
@property (nonatomic, assign, readonly) float satisfaction;     // 满意度
@end

// 接起会话数model
@interface HDAgentServedConversationModel: NSObject
- (instancetype)initWithDictionary:(NSDictionary *)aDict;
@property (nonatomic, assign, readonly) NSInteger index;
@property (nonatomic, strong, readonly) NSString *agentName;
@property (nonatomic, assign, readonly) NSInteger servedCount;
@end

@interface HDAverageFirstResponseTimeModel: NSObject
- (instancetype)initWithDictionary:(NSDictionary *)aDict;
@property (nonatomic, assign, readonly) NSString *agentName;
@property (nonatomic, assign, readonly) NSInteger seconds;
@property (nonatomic, assign, readonly) NSInteger index;
@end

@interface HDAgnetSatisfactionEvaluationModel: NSObject
- (instancetype)initWithDictionary:(NSDictionary *)aDict;
@property (nonatomic, assign, readonly) NSString *agentName;
@property (nonatomic, assign, readonly) float averageScore;
@property (nonatomic, assign, readonly) NSInteger index;
@end

@interface HDAgentMeanResponseTimeModel: NSObject
- (instancetype)initWithDictionary:(NSDictionary *)aDict;
@property (nonatomic, assign, readonly) NSString *agentName;
@property (nonatomic, assign, readonly) NSInteger seconds;
@property (nonatomic, assign, readonly) NSInteger index;
@end

