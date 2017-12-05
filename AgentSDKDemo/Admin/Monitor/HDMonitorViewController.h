//
//  HDMonitorViewController.h
//  AgentSDKDemo
//
//  Created by afanda on 12/4/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <UIKit/UIKit.h>


//状态分部
#define kMonitorStatus @"/daas/internal/monitor/agent/status/dist"
//客服负载情况
#define kMonitorLoad @"/daas/internal/monitor/agent/load"
//会话数
#define kMonitorSessionCount @"/daas/internal/monitor/session/total"
//=访客来源
//渠道
#define kMonitorVisitorOrigin @"/daas/internal/monitor/visitor/total"
//关联
#define kMonitorVisitorOringinChannel @"/daas/internal/monitor/visitor/total/channel"\
//服务质量
#define kMonitorQuality @"/daas/internal/monitor/quality/total"
//接起会话数,客服:O_AGENT,技能组:O_GROUP
#define kMonitorPickUpSessionCount @"/daas/internal/monitor/list/session/start?top=true&objectType=%@"
//平均首次响应,客服:O_AGENT,技能组:O_GROUP
#define kMonitorFirstResponse @"/daas/internal/monitor/list/first/response?top=true&objectType=%@"
//满意度,客服:O_AGENT,技能组:O_GROUP
#define kMonitorSatisfaction @"/daas/internal/monitor/list/visitor/mark?top=true&objectType=%@"
//平均响应时长,客服:O_AGENT,技能组:O_GROUP
#define kMonitorAverageResponse @"/daas/internal/monitor/list/response/time?top=true&objectType=%@"

@interface HDMonitorViewController : UIViewController




@end
