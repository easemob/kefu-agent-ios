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

#define KScreenWidth [UIApplication sharedApplication].keyWindow.size.width
#define KScreenHeight [UIApplication sharedApplication].keyWindow.size.height

#define NOTIFICATION_ADD_COMMENT @"addComment"
#define NOTIFICATION_ADD_SUMMARY_RESULTS @"addSummaryResult"
#define USERDEFAULTS_DEVICE_TREE [NSString stringWithFormat:@"%@tagTree",[HDNetworkManager shareInstance].loginUsername]


#endif /* LocalDefine_h */
