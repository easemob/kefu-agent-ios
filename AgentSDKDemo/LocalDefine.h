//
//  LocalDefine.h
//  AgentSDKDemo
//
//  Created by afanda on 4/17/17.
//  Copyright © 2017 环信. All rights reserved.
//

#ifndef LocalDefine_h
#define LocalDefine_h
#define DEFAULT_CELLHEIGHT 44
#define DEFAULT_CELLHEADERHEIGHT 20
#define DEFAULT_CHAT_CELLHEIGHT 60
#define DEFAULT_CONVERSATION_CELLHEIGHT 60
#define kTableViewHeaderAndFooterColor RGBACOLOR(242, 242, 242, 1)

#define kNotiCenter [NSNotificationCenter defaultCenter]
#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
#define kHomeViewLeft 70
#define isIPHONEX ([UIScreen mainScreen].bounds.size.height == 812 ? 1 : 0)
#define navigationBarHeight ([UIScreen mainScreen].bounds.size.height == 88 ?: 64)
#define iPhoneXBottomHeight  ([UIScreen mainScreen].bounds.size.height == 812 ? 34 : 0)

#define NOTIFICATION_ADD_COMMENT @"addComment"
#define NOTIFICATION_ADD_SUMMARY_RESULTS @"addSummaryResult"
#define USERDEFAULTS_DEVICE_TREE [NSString stringWithFormat:@"%@tagTree",[HDClient sharedClient].currentAgentUser.username]
#define DefaultUsername @"kefuDefaultUsername"

#define StandardUserDefaults  [NSUserDefaults standardUserDefaults]

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define WEAK_SELF typeof(self) __weak weakSelf = self;
#define kStrongSelf __strong __typeof(self) strongSelf = self;

#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isIPhone4 ([[UIScreen mainScreen] bounds].size.height == 480 )

#define BUTTON_TITLE_COLOR RGBACOLOR(0x4c, 0x4c, 0x4c, 1)

//系统版本号
#define kSystemVersion [[UIDevice currentDevice].systemVersion floatValue]

//APPKEY
#define UMENG_APPKEY @"55ff6d1fe0f55adff00004bc"

#define USERDEFAULTS_QUICK_REPLY [NSString stringWithFormat:@"%@quickReply",[HDClient sharedClient].currentAgentUser.username]
#pragma mark -  login
#define USERDEFAULTS_LOGINUSERNAME @"easemob_kefu_username"
#define USERDEFAULTS_LOGINPASSWORD @"easemob_kefu_password"
#define USERDEFAULTS_SAVEPASSWORD @"easemob_kefu_save_password"


//Notification 名字
// 访客发起视频邀请 参数都准备好后 加入房间的通知
#define HDCALL_liveStreamInvitation_CreateAgoraRoom @"HDCALL_liveStreamInvitation_CreateAgoraRoom"

#define HDCALL_KefuRtcCallRinging_VEC_CreateAgoraRoom @"HDCALL_KefuRtcCallRinging_VEC_CreateAgoraRoom"
#define HDCALL_AGENT_STATE_Ringing @"HDCALL_AGENT_STATE_Ringing_VEC_CreateAgoraRoom"
// 视频结束 发送通知 更新界面
#define HDCALL_videoPlayback_end @"HDCALL_videoPlayback_end"
// 视频结束 发送通知 显示测试界面
#define HDCALL_KefuRtcCallRinging_VEC_sessionhistory @"HDCALL_KefuRtcCallRinging_VEC_sessionhistory"



// 智能辅助html 高度通知
#define HDSmart_HTML_Height @"HDSmart_HTML_Height"


#define hd_dispatch_main_sync_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }


#define hd_dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}

#endif /* LocalDefine_h */
