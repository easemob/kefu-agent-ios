//
//  UserModel.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentSDKTypes.h"

#define USER_VISITOR @"visitorUser"
#define USER @"user"
#define USER_ID @"userId"
#define USER_TENANTID @"tenantId"
#define USER_USERNAME @"username"
#define USER_TOKEN @"token"
#define USER_NICENAME @"nicename"
#define USER_TRUENAME @"trueName"
#define USER_WELCOME @"welcomeMessage"
#define USER_PHONE @"mobilePhone"
#define USER_STATE @"onLineState"
#define USER_CURSTATE @"currentOnLineState"
#define USER_SERVICECOUNT @"maxServiceSessionCount"
#define USER_ROLES @"roles"
#define USER_AGENTNUMBER @"agentNumber"
#define USER_AVATAR @"avatar"

#define USER_STATE_ONLINE @"Online"
#define USER_STATE_BUSY @"Busy"
#define USER_STATE_LEAVE @"Leave"
#define USER_STATE_HIDDEN @"Hidden"
#define USER_STATE_OFFLINE @"Offline"

#define VEC_USER_STATE_ONLINE @"IDLE"           //空闲
#define VEC_USER_STATE_BUSY @"BUSY"             //繁忙
#define VEC_USER_STATE_REST @"REST"             //小休
#define VEC_USER_STATE_OFFLINE @"OFFLINE"       //离线
#define VEC_USER_STATE_RINGING @"RINGING"       //振铃中
#define VEC_USER_STATE_PROCESSING @"PROCESSING" //通话中



#define USER_STATUS_ENABLE @"Enable"
#define USER_STATUS_DISABLE @"Disable"

//#define USER_ @""
//#define USER_ @""
//#define USER_ @""

#define VISTORUSER_QQ @"qq"
#define VISTORUSER_PHONE @"phone"
#define VISTORUSER_EMAIL @"email"
#define VISTORUSER_COMPANYNAME @"companyName"
#define VISTORUSER_DESC @"description"
#define VISTORUSER_USERID @"visitorUserId"
#define VISTORUSER_callback_user @"callback_user"
#define VISTORUSER_userDefineColumn @"userDefineColumn"
#define VISTORUSER_userNickname @"userNickname"
#define VISTORUSER_weixin @"weixin"
#define VISTORUSER_sex @"sex"
#define VISTORUSER_openid @"openid"

#define IMUSER @"imUser"
#define IMUSER_EASEMOBID @"easemobId"
#define IMUSER_EASEMOBPASSWORD @"easemobPassword"
#define IMUSER_USERID @"userId"
#define IMUSER_LOGINLOCATION @"loginLocation"

#define IFRAME_TITLE @"IframeTabTitle"
#define IFRAME_ENCRYPYALL @"IframeEcryptAll"
#define IFRAME_BASEURL @"IframeBaseUrl"
#define IFRAME_VISITOR_INFO_ENCRYPT_KEY @"IframeVisitorInfoEncryptKey"

#define IFRAME_ROBOT_TITLE @"IframeRobotTabTitle"
#define IFRAME_ROBOT_ENCRYPYALL @"IframeRobotEcryptAll"
#define IFRAME_ROBOT_BASEURL @"IframeRobotUrl"
#define IFRAME_ROBOT_VISITOR_INFO_ENCRYPT_KEY @"IframeEncryptRobotKey"



@interface UserModel : NSObject<NSCoding>

@property (nonatomic, copy) NSString *agentId;
@property (nonatomic, copy) NSString *tenantId; //租户ID
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *nicename;
@property (nonatomic, copy) NSString *truename;
@property (nonatomic, copy) NSString *welcomeMessage;
@property (nonatomic, copy) NSString *mobilePhone;
@property (nonatomic, assign) NSInteger maxServiceSessionCount;
@property (nonatomic, copy) NSString *onLineState;    //Online;Hidden
@property (nonatomic, copy) NSString *currentOnLineState;    //Online;Hidden
@property (nonatomic, copy) NSString *roles;
@property (nonatomic, copy) NSString *agentNumber;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) BOOL greetingEnable;
@property (nonatomic, assign) BOOL appAssistantEnable;
@property (nonatomic, assign) BOOL sendPattern; //yes 自动发送 no 手动

@property (nonatomic, assign) BOOL smartEnable; //智能辅助 灰度有没有开
@property (nonatomic, assign) BOOL agoraVideoEnable; //在线视频 灰度有没有开
@property (nonatomic, copy) NSString *greetingContent;
@property (nonatomic, copy) NSString *customUrl;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) HDAgentLoginStatus agentStatus;
@property (nonatomic, assign) HDVECAgentLoginStatus vecAgentStatus;

@property (nonatomic, copy, readonly) NSString *userType;

@property (nonatomic, assign) BOOL allowAgentChangeMaxSessions;
@property (nonatomic, assign) BOOL isStopSessionNeedSummary;
@property (nonatomic, assign) BOOL serviceSessionTransferPreScheduleEnable; //转接会话是否需要对方确认

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)updateUser:(NSDictionary *)dictionary;

- (NSDictionary *)userModelDicDesc;

@end

@interface VisitorUserModel : UserModel

@property (nonatomic, copy) NSString *qq;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *userDescription;
@property (nonatomic, copy) NSString *callback_user;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *tags;
@property (nonatomic, copy) NSString *trueName;
@property (nonatomic, copy) NSString *userDefineColumn;
@property (nonatomic, copy) NSString *userNickname;
@property (nonatomic, copy) NSString *weixin;
@property (nonatomic, copy) NSString *openid;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface IMUserModel : NSObject<NSCoding>

@property (nonatomic, copy) NSString *easemobId;
@property (nonatomic, copy) NSString *easemobPassword;
@property (nonatomic, copy) NSString *loginLocation;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *appkey;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)updateUser:(NSDictionary *)dictionary;

@end
