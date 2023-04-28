//
//  HDAgoraCallManagerDelegate.h
//  HelpDeskLite
//
//  Created by houli on 2022/1/6.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDKeyCenter.h"
@protocol HDCallManagerDelegate <NSObject>

@optional

/*!
 *  \~chinese
 *  接收到视频请求
 *  @param keyCenter   创建视频请求必要的参数
 *
 *  \~english
 *  Receiving a Video request
 *
 */
- (void)onCallReceivedParameter:(HDKeyCenter *)keyCenter;

/*!
 *  \~chinese
 *    第三方坐席进来 获取对应的坐席信息
 *  @param thirdAgentNickName   坐席昵称
 *
 *  \~english
 *  Receiving a Video request
 *
 */
- (void)onCallReceivedInvitation:(NSString *)thirdAgentNickName withUid:(NSString *)uid;
/*!
 *  \~chinese
 *     vec 独立访客端 收到 坐席拒绝的通知
 *
 */
- (void)onCallHangUpInvitation;

/*!
 *  \~chinese
 *     vec 独立访客端 收到 坐席信息推送
 *
 */
- (void)onCallLinkMessagePush:(NSDictionary *)dic;
/*!
 *  \~chinese
 *     vec 独立访客端 收到 ocr 识别
 *
 */
- (void)onCallLOcrIdentify:(NSDictionary *)dic;
/*!
 *  \~chinese
 *     vec 独立访客端 收到 身份认证
 *
 */
- (void)onCallFaceIdentify:(NSDictionary *)dic;
/*!
 *  \~chinese
 *     vec 独立访客端 收到 数字签名
 *
 */
- (void)onCallSignIdentify:(NSDictionary *)dic;
@end 

