//
//  AgoraViewController.h
//  CustomerSystem-ios
//
//  Created by houli on 2022/1/5.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, HDCallAlertType) {
    HDCallAlertTypeVideo, //  视频界面
};
@interface HDAgoraCallViewController : UIViewController
typedef void (^HangAgroaUpCallback)(HDAgoraCallViewController *callVC, NSString *timeStr);
@property (nonatomic, copy) HangAgroaUpCallback hangUpCallback;


/**
 *  视频通话界面
 */
+(id)alertLoginWithView:(UIView *)view;
/**
 *  界面展示
 */
-(void)showView;
/**
 *  界面移除
 */
-(void)hideView;
/*!
 *  \~chinese
 *  初始化被叫页面
 *
 *  @param aAgentName  主叫坐席名称
 *  @param aAvatarStr  被叫(自己)头像名称
 *  @param aNickname   被叫(自己)昵称
 *  @param callback    呼叫结束后回调
 */
+ (HDAgoraCallViewController *)hasReceivedCallWithAgentName:(NSString *)aAgentName
                                             avatarStr:(NSString *)aAvatarStr
                                              nickName:(NSString *)aNickname
                                        hangUpCallBack:(HangAgroaUpCallback)callback;

/*!
 *  \~chinese
 *  初始化被叫页面
 *
 *  @param aAgentName  主叫坐席名称
 *  @param aAvatarStr  被叫(自己)头像名称
 *  @param aNickname   被叫(自己)昵称
 */
+ (HDAgoraCallViewController *)hasReceivedCallWithAgentName:(NSString *)aAgentName
                                             avatarStr:(NSString *)aAvatarStr
                                              nickName:(NSString *)aNickname;
@end

NS_ASSUME_NONNULL_END
