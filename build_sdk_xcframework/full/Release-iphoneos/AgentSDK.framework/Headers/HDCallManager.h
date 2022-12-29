//
//  HDAgoraCallManager.h
//  HelpDeskLite
//
//  Created by houli on 2022/1/6.
//  Copyright © 2022 hyphenate. All rights reserved.
#import <Foundation/Foundation.h>
#import "HDCallManagerDelegate.h"
#import "HDGrayModel.h"
#import "HDThirdAgentModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface HDCallManager : NSObject
@property (nonatomic, strong) HDKeyCenter *keyCenter;
@property (nonatomic, strong) NSString * conversationId;;
@property (nonatomic, strong) NSString * rtcSessionId;;
@property (nonatomic, strong) HDThirdAgentModel * thirdAgentModel;
@property (nonatomic, strong) NSMutableDictionary * agentDicModel;

+ (instancetype _Nullable )shareInstance;

/*!
 *  \~chinese
 *  发起视频邀请，发起后，客服会收到申请，客服同意后，会自动给访客拨过来。
 *
 *  @param aImId   会话id
 *  @param aContent   文本内容
 *
 */
- (HDMessage *)creteVideoInviteMessageWithImId:(NSString *)aImId
                                       content:(NSString *)aContent;


/*!
 *  \~chinese
 *   vec 独立访客端 接收 坐席主动发过来的 视频邀请
 *
 *  @param aImId   会话id
 *  @param aContent   文本内容
 *
 */
- (HDMessage *)hd_visitorAcceptInvitationMessageWithImId:(NSString *)aImId
                                       content:(NSString *)aContent;

/*!
 *  \~chinese
 *   vec 独立访客端 拒绝 坐席主动发过来的 视频邀请
 *
 *  @param aImId   会话id
 *  @param aContent   文本内容
 *
 */
- (HDMessage *)hd_visitorRejectInvitationMessageWithImId:(NSString *)aImId
                                       content:(NSString *)aContent;
#pragma mark - Delegate
/*!
 *  \~chinese
 *  添加回调代理
 *
 *  @param aDelegate  要添加的代理
 *  @param aQueue     执行代理方法的队列
 *
 *  \~english
 *  Add delegate
 *
 */
- (void)addDelegate:(id<HDCallManagerDelegate>_Nullable)aDelegate
      delegateQueue:(dispatch_queue_t _Nullable )aQueue;

/*!
 *  \~chinese
 *  移除回调代理
 *
 *  @param aDelegate  要移除的代理
 *
 *  \~english
 *  Remove delegate
 *
 */
- (void)removeDelegate:(id<HDCallManagerDelegate>_Nullable)aDelegate;

/*!
 *  \~chinese
 *  获取灰度管理
 *
 *  @param grayName  灰度的名称
 *
 *  \~english
 *  Remove delegate
 *
 */
- (HDGrayModel *)getGrayName:(NSString *)grayName;

/*!
 *  \~chinese
 *  初始化灰度管理接口
 *
 */
- (void)initGray;

/*!
 *  \~chinese
 *  获取初始样式以及功能设置
 */
- (void)hd_getInitVECSettingWithCompletion:(void(^)(id  responseObject, HDError *error))aCompletion;

/*!
 *  \~chinese
 *  访客挂断接口   /v1/kefurtc/tenant/{tenantId}/session/{rtcSessionId}/visitor/{visitorId}/close 
 */
- (void)hd_hangUpVECSessionId:(NSString *)rtcSessionId WithVisitorId:(NSString *)visitorId Completion:(void(^)(id  responseObject, HDError *error))aCompletion;


/*!
 *  \~chinese
 *   提交签名
 */
- (void)hd_commitSignData:(NSData *)data WithVisitorId:(NSString *)visitorId withFlowId:(NSString *)flowId Completion:(void(^)(id  responseObject, HDError *error))aCompletion;


/*!
 *  \~chinese
 *     信息推送 上报接口
 */
- (void)hd_pushBusinessReportWithFlowId:(NSString *)flowId withAction:(NSString *)action  withType:(NSString *)type  withUrl:(NSString *)url withContent:(NSString *)content Completion:(void(^)(id  responseObject, HDError *error))aCompletion;



@end

NS_ASSUME_NONNULL_END
