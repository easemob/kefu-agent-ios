//
//  HDSetManager.h
//  AgentSDK
//
//  Created by afanda on 9/20/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentSDKTypes.h"
#import "HDUserTag.h"


@interface HDSetManager : NSObject


/**
 更新问候语

 @param content 问候语
 @param completion 完成回调
 */
- (void)updateGreetingContent:(NSString *)content completion:(void(^)(id responseObject,HDError *error))completion;


/**
 修改个人信息

 @param key key
 @param value 值
 @param completion 完成回调
 */
- (void)modifyInfoWithKey:(NSString *)key value:(NSString *)value completion:(void(^)(id responseObject,HDError *error))completion;


/**
 开启、关闭问候语

 @param enable YES为开启、NO为关闭
 */
- (void)enableGreeting:(BOOL)enable completion:(void(^)(id responseObject,HDError *error))completion;

/**
 开启、关闭 移动助手

 @param enable YES为开启、NO为关闭
 */
- (void)enableAppAssistant:(BOOL)enable completion:(void(^)(id responseObject,HDError *error))completion;

/**
 智能辅助 搜索接口
 */
- (void)kf_searchAnswerWithQuestion:(NSString *)question withSessionId:(NSString *)sessionid withMsgId:(NSString *)msgid completion:(void(^)(id responseObject,HDError *error))completion;

/**
   智能辅助 cache
 */
- (void)kf_cacheAnswerWithQuestion:(NSString *)question withSessionId:(NSString *)sessionid withMsgId:(NSString *)msgid completion:(void (^)(id, HDError *))completion;
/**
 智能辅助 获取配模式接口 
 */
- (void)kf_getCooperationWithPatternCompletion:(void(^)(id responseObject,HDError *error))completion;

/**
  设置 匹配模式接口 sendPattern
 */
- (void)kf_setCooperationWithsendPattern:(NSInteger)sendPattern withAnswerMatchPattern:(NSInteger)answerMatchPattern  Completion:(void(^)(id responseObject,HDError *error))completion;


/**
  获取灰度接口
 */
- (void)kf_getInitGrayCompletion:(void(^)(id responseObject,HDError *error))completion;

/**
 https://077986.kefu.easemob.com/v1/cooperation/answer/statistics?tenantId=77986&msgId=&sessionId=&operationEnum=send&answerId=51473690-8b90-42f2-84fb-5f86c751102a&_=1653228753175
  统计接口 发送 （send）和 引用 （quote） 调用
 
 operationEnum = send；
 operationEnum =quote；
 */
- (void)kf_getCooperationWithstatisticsWithOperationEnum:(NSString *)operationEnum withAnswerId:(NSString *)answerId  withSessionId:(NSString *)sessionid withMsgId:(NSString *)msgid completion:(void(^)(id responseObject,HDError *error))completion;

/**
 上传头像

 @param imageData 图片data
 @param completion 完成回调
 */
- (void)asyncUploadImageWithFile:(NSData*)imageData
                       completion:(void (^)(NSString *url, HDError *error))completion;



/**
 访客标签

 @param userId userId
 @param completion 完成回调
 */
- (void)getVisitorUserTagsWithUserId:(NSString *)userId completion:(void(^)(id responseObject,HDError *error))completion;


/**
 修改访客标签

 @param userTag 访客id
 @param completion 完成回调
 */
- (void)updateVisitorUserTagWithUserTag:(HDUserTag *)userTag completion:(void(^)(id responseObject,HDError *error))completion;


/**
 修改最大接入数

 @param userNum 人数
 @param completion 完成回调
 */
- (void)updateServiceUsersWithNum:(NSString *)userNum completion:(void(^)(id responseObject,HDError *error))completion;


/**
 更新在线状态

 @param status 状态
 @param completion 完成回调
 */
- (void)updateOnLineStatusWithStatus:(HDOnlineStatus)status
                          completion:(void (^)(id responseObject, HDError *error))completion;



@end



