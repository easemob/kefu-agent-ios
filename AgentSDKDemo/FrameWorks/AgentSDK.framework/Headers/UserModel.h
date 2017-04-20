//
//  UserModel.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

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
#define USER_STATE_OFFLINE @"Hidden"

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

#define IMUSER @"imUser"
#define IMUSER_EASEMOBID @"easemobId"
#define IMUSER_EASEMOBPASSWORD @"easemobPassword"
#define IMUSER_USERID @"userId"
#define IMUSER_LOGINLOCATION @"loginLocation"

@interface UserModel : NSObject<NSCoding>

@property (copy, nonatomic) NSString *userId;
@property(nonatomic,copy) NSString *projectID; //留言id
@property (copy, nonatomic) NSString *tenantId; //租户ID
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *token;
@property (copy, nonatomic) NSString *nicename;
@property (copy, nonatomic) NSString *truename;
@property (copy, nonatomic) NSString *welcomeMessage;
@property (copy, nonatomic) NSString *mobilePhone;
@property (assign, nonatomic) NSInteger maxServiceSessionCount;
@property (copy, nonatomic) NSString *onLineState;    //Online;Hidden
@property (copy, nonatomic) NSString *currentOnLineState;    //Online;Hidden
@property (copy, nonatomic) NSString *roles;
@property (copy, nonatomic) NSString *agentNumber;
@property (copy, nonatomic) NSString *avatar;
@property (assign, nonatomic) BOOL greetingEnable;
@property (copy, nonatomic) NSString *greetingContent;
@property (copy, nonatomic) NSString *customUrl;
@property (copy, nonatomic) NSString *status;

@property (assign, nonatomic) BOOL allowAgentChangeMaxSessions;
@property (assign, nonatomic) BOOL isStopSessionNeedSummary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)updateUser:(NSDictionary *)dictionary;

- (NSDictionary*)userModelDicDesc;

@end

@interface VisitorUserModel : UserModel

@property (copy, nonatomic) NSString *qq;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *companyName;
@property (copy, nonatomic) NSString *userDescription;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface IMUserModel : NSObject<NSCoding>

@property (copy, nonatomic) NSString *easemobId;
@property (copy, nonatomic) NSString *easemobPassword;
@property (copy, nonatomic) NSString *loginLocation;
@property (copy, nonatomic) NSString *userId;

@property (copy, nonatomic) NSString *appkey;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)updateUser:(NSDictionary *)dictionary;

@end
