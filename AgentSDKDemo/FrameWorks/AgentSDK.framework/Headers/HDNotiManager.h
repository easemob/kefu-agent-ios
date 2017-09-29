//
//  HDNotiManager.h
//  AgentSDK
//
//  Created by afanda on 5/19/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDNotifyModel.h"
#import "HDVisitorInfo.h"
@interface HDNotiManager : NSObject

/**
 未读数
 */
@property(nonatomic,assign) NSInteger unreadCount;


/**
 消息总数
 */
@property(nonatomic,assign) NSInteger totalCount;

/**
 获取通知消息

 @param pageIndex 第几页
 @param pageSize 每页数据个数
 @param status 已读还是未读
 @param type 消息类型
 @param parameters 预留参数暂传nil
 @param completion 完成请求的回调
 */
- (void)asyncGetNoticeWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize status:(HDNoticeStatus)status type:(HDNoticeType)type prameters:(NSDictionary *)parameters completion:(void(^)(NSArray <HDNotifyModel *> *notices,HDError *error))completion;


/**
 未读通知消息标记为已读

 @param ids 通知的id数组
 @param parameters 预留参数暂传nil
 @param completion 完成请求的回调
 */
- (void)asyncPUTMarkNoticeASReadWithUnreadNoticeIds:(NSArray <NSString *> *)ids parameters:(NSDictionary *)parameters completion:(void(^)(id responseObjcet,HDError *error))completion;


/**
 创建会话

 @param visitorId visitorId
 @param completion 完成回调
 */
- (void)asyncMessageCenterCreateSessionWithVisitorId:(NSString *)visitorId Completion:(void(^)(HDConversation *conversation,HDError *error))completion;


/**
 获取访客资料

 @param visitorId
 @param completion 完成回调
 */
- (void)asyncFetchVisitorItemsWithVisitorId:(NSString *)visitorId completion:(void(^)(HDVisitorInfo *visitorInfo, HDError *error))completion ;


/**
 更新访客资料

 @param customerId 访客id，获取访客资料的时候拿到
 @param parameters 参数
 @param completion 完成回调
 */
- (void)updateVisitorItemWithCustomerId:(NSString *)customerId
                              visitorId:(NSString *)visitorId
                             parameters:(NSDictionary *)parameters
                             completion:(void(^)(id responseObject, HDError *error))completion ;


@end
