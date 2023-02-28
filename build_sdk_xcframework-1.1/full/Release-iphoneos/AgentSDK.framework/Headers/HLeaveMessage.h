//
//  HLeaveMessage.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2018/6/19.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentSDK.h"

typedef enum : NSUInteger {
    HLeaveMessageType_untreated = 0,    // 未处理
    HLeaveMessageType_processing,       // 处理中
    HLeaveMessageType_resolved,         // 已解决
    HLeaveMessageType_custom            // 自定义
} HLeaveMessageType;

// 留言创建者
@interface HLeaveMessageCreator : NSObject
@property (nonatomic, strong) NSString *username;           // username
@property (nonatomic, strong) NSString *nickname;           // 昵称
@property (nonatomic, strong) NSString *company;            // 公司
@property (nonatomic, strong) NSString *email;              // 邮箱
@property (nonatomic, strong) NSString *phone;              // 电话
@property (nonatomic, strong) NSString *QQ;                 // QQ
@end

typedef enum : NSUInteger {
    HAssignee_Agent = 0
} HAssigneeType;

// 被分配人
@interface HAssignee : NSObject
@property (nonatomic, strong) NSString *agentId;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, assign) HAssigneeType type;
@end


// 留言
@interface HLeaveMessage : NSObject
@property (nonatomic, strong) NSString *leaveMessageId;     // 留言id
@property (nonatomic, assign) HChannelType channelType;     // 留言渠道
@property (nonatomic, assign) HLeaveMessageType type;       // 留言类型 (未处理，处理中，已解决，未分配)
@property (nonatomic, strong) HLeaveMessageCreator *creator; // 创建者
@property (nonatomic, strong) HAssignee *assignee;          // 被分配人
@property (nonatomic, strong) NSString *createDate;         // 创建时间
@property (nonatomic, strong) NSString *updateDate;         // 修改时间
@property (nonatomic, strong) NSString *subject;            // 主题
@property (nonatomic, strong) NSString *content;            // 内容
@property (nonatomic, strong) NSString *sessionId;          // 留言所关联的会话
@property (nonatomic, strong) NSString *version;             // 版本(目前无用)
@end

