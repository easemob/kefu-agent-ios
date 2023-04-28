//
//  HDMonitorManager.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 17/01/2018.
//  Copyright © 2018 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentSDKTypes.h"
#import "UserModel.h"
#import "HDMonitorModels.h"


@interface HDMonitorManager : NSObject

// 客服状态分布，
- (void)asyncFetchAgentStatusDistWithCompletion:(void(^)(HDAgentStatusDistCountModel *distModel, HDError *error))aCompletion;

// 客服负载状态
- (void)asyncFetchAgentLoadWithCompletion:(void(^)(HDAgentLoadCountModel *model, HDError *error))aCompletion;

// 访客排队情况
- (void)asyncFetchWaitCountWithCompletion:(void(^)(HDVisitorWaitCountModel *model, HDError *error))aCompletion;

// 会话数
- (void)asyncFetchSessionTotalWithCompletion:(void(^)(HDAgentSessionCountModel *model, HDError *error))aCompletion;

// 访客来源
- (void)asyncFetchVistorTotalWithCompletion:(void(^)(HDVisterSourceModel *model, HDError *error))aCompletion;

// 服务质量
- (void)asyncFetchQualityTotalWithCompletion:(void(^)(HDAgentQualityModel *model, HDError *error))aCompletion;

// 接起会话数
- (void)asyncFetchServedConversationStartWithObjectType:(HDObjectType)aObjectType
                                                  isTop:(BOOL)isTop
                                             completion:(void(^)(NSArray *servedConversationModels, HDError *error))aCompletion ;

// 平均首次首响时长
- (void)asyncFetchListFirstResponseWithObjectType:(HDObjectType )aObjectType
                                            isTop:(BOOL)isTop
                                       completion:(void(^)(NSArray *averageFirstResponseTimeModels, HDError *error))aCompletion;


// 满意度
- (void)asyncFetchListVistorMarkWithObjectType:(HDObjectType)aObjectType
                                         isTop:(BOOL)isTop
                             completion:(void(^)(NSArray *agnetSatisfactionEvaluationModels, HDError *error))aCompletion;

// 平均响应时长
- (void)asyncFetchListResponseWithObjectType:(HDObjectType)aObjectType
                                       isTop:(BOOL)isTop
                           completion:(void(^)(NSArray *agentMeanResponseTimeModels, HDError *error))aCompletion;

@end
